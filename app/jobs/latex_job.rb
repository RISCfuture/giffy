# LaTeX processing job for use with the `/latex` command (see
# {LatexController}).

class LatexJob < ApplicationJob
  queue_as :default

  # Uses latex to generate an image of an equation, then uploads it to S3 and
  # posts the URL to the Slack channel. Also echoes the original command to the
  # channel.
  #
  # @param [Hash<Symbol, String>] command The original Slack command, obtained
  #   by calling {Slack::Command}#to_h. This object is used to retrieve the
  #   LaTeX equation, impersonate the user, and post to the channel.

  def perform(command)
    command = Slack::Command.new(command)
    Slack.instance.echo command

    latex = wrap(sanitize(command.text))

    convert latex do |url|
      Slack.instance.webhook_message command.channel_id, url
    end
  end

  private

  def wrap(latex)
    <<-LATEX
\\documentclass[preview]{standalone}
\\begin{document}
$#{latex}$
\\end{document}
    LATEX
  end

  def sanitize(latex)
    latex.gsub('$', '\\$')
  end

  # @private
  PDFTEX_BINARIES = %w(pdflatex pdftex)

  def convert(latex)
    pdftex = PDFTEX_BINARIES.detect { |b| system 'which', b }
    raise LaTeXError, "LaTeX not installed" unless pdftex

    ident = Digest::MD5.hexdigest(latex)

    tex_file = Tempfile.new([ident, '.tex'])
    tex_file.write latex
    tex_file.close

    Dir.mktmpdir(ident) do |output_directory|
      system pdftex, '-interaction=nonstopmode', "--output-directory=#{output_directory}", tex_file.path

      pdf_path = File.join(output_directory, File.basename(tex_file.path, '.tex') + '.pdf')
      raise LaTeXError, "Invalid LaTeX" unless File.exist?(pdf_path)

      png_path = Rails.root.join('tmp', "#{ident}.png").to_s
      system 'convert', '-density', '300', pdf_path, '-quality', '90', png_path
      raise LaTeXError, "Couldn't convert to PNG" unless File.exist?(png_path)

      File.open(png_path, 'rb') do |file|
        S3.put_object bucket: 'giffy-latex', key: "images/#{ident}.png", body: file
      end
      S3.put_object_acl acl: 'public-read', bucket: 'giffy-latex', key: "images/#{ident}.png"

      yield "https://giffy-latex.s3-us-west-1.amazonaws.com/images/#{ident}.png"

      tex_file.unlink
    end
  end

  # Generic error class for all LaTeX errors.

  class LaTeXError < StandardError
  end
end