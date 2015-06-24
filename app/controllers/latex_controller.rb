require 'slack'
require 'digest/md5'
require 'tempfile'

class LatexController < ApplicationController
  before_action :validate_command
  report_errors_to_slack

  def display
    check_security command.text
    latex = wrap(sanitize(command.text))

    convert latex do |url|
      Slack.instance.echo command
      Slack.instance.webhook_message command.channel_id, url
    end

    head :ok
  rescue LaTeXError
    render text: $!.to_s, status: :internal_server_error
  end

  private

  def check_security(latex)
    raise LaTeXError, "Insecure LaTeX command" if %w(\\input \\write \\include).any? { |cmd| latex.include?(cmd) }
  end

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

  def convert(latex)
    ident = Digest::MD5.hexdigest(latex)

    tex_file = Tempfile.new([ident, '.tex'])
    tex_file.write latex
    tex_file.close

    Dir.mktmpdir(ident) do |output_directory|
      system 'pdflatex', '-interaction=nonstopmode', "--output-directory=#{output_directory}", tex_file.path

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

  class LaTeXError < StandardError
  end
end
