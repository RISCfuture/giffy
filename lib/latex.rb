require 'digest/md5'
require 'tempfile'
require 'addressable/template'

# Interface for rendering LaTeX equations in various formats and uploading them
# to AWS S3. Note that only math-mode equations are supported.
#
# @example
#   latex = LaTeX.new('y=mx+b')
#   latex.upload
#   puts latex.url

class LaTeX
  # @return [String] The LaTeX equation.
  attr_accessor :equation

  # Creates a new instance.
  #
  # @param [String] equation The LaTeX equation.

  def initialize(equation)
    self.equation = equation
  end

  # Writes the equation to a temporary .tex file intended for display as a
  # borderless image.
  #
  # @yield [path] A block to run with the generated .tex file before it is
  #   deleted.
  # @yieldparam [String] path The path to the temporary .tex file.

  def to_tex_file
    check_security!

    Dir.mktmpdir(ident) do |output_directory|
      tex_path = File.join(output_directory, ident + '.tex')
      File.open(tex_path, 'w') { |f| f.puts wrapped_equation }
      yield tex_path
      File.unlink tex_path
    end
  end

  # Renders the equation to a temporary .pdf file intended for display as a
  # borderless image.
  #
  # @yield [path] A block to run with the rendered .pdf file before it is
  #   deleted.
  # @yieldparam [String] path The path to the temporary .pdf file.
  # @raise [LaTeX::BinaryNotInstalled] If pdftex is not properly installed.
  # @raise [LaTeX::PDFConversionFailed] If pdftex fails to complete.

  def to_pdf_file
    to_tex_file do |tex_path|
      Dir.mktmpdir(ident) do |output_directory|
        system pdftex, *PDFTEX_OPTIONS, "--output-directory=#{output_directory}", tex_path
        pdf_path = File.join(output_directory, ident + '.pdf')
        raise PDFConversionFailed.new(self) unless File.exist?(pdf_path)
        yield pdf_path
        File.unlink pdf_path
      end
    end
  end

  # Renders the equation to a temporary .png file intended for display as a
  # borderless image.
  #
  # @yield [path] A block to run with the rendered .png file before it is
  #   deleted.
  # @yieldparam [String] path The path to the temporary .png file.
  # @raise [LaTeX::BinaryNotInstalled] If ImageMagick is not properly installed.
  # @raise [LaTeX::PNGConversionFailed] If convert fails to complete.

  def to_png_file
    to_pdf_file do |pdf_path|
      Dir.mktmpdir(ident) do |output_directory|
        png_path = File.join(output_directory, ident + '.png')
        system convert, *CONVERT_OPTIONS, pdf_path, png_path
        raise PNGConversionFailed.new(self) unless File.exist?(png_path)
        yield png_path
        File.unlink png_path
      end
    end
  end

  # Renders the equation as a borderless image and uploads it to AWS S3.
  #
  # @see #url

  def upload
    to_png_file do |png_path|
      File.open(png_path, 'rb') do |file|
        S3.put_object bucket: Giffy::Configuration.aws.bucket, key: key, body: file
      end
      S3.put_object_acl acl: 'public-read', bucket: Giffy::Configuration.aws.bucket, key: key
    end
  end

  # @return [Addressable::URI] The URL to the uploaded equation image on S3.
  #   This URL will only be valid after {#upload} has been called.

  def url
    @@url_template ||= Addressable::Template.new(Giffy::Configuration.aws.url_template)
    @@url_template.expand 'bucket' => Giffy::Configuration.aws.bucket,
                          'region' => Giffy::Configuration.aws.region,
                          'key'    => key
  end

  # @return [true, false] `false` if this equation includes any blacklisted,
  #   insecure TeX commands; `true` otherwise.

  def secure?
    INSECURE_COMMANDS.none? { |cmd| equation.include?(cmd) }
  end

  # Calls {#secure?} and raises an error if it returns `false`.
  #
  # @raise [LaTeX::InsecureCommand] If the equation is insecure.

  def check_security!
    raise InsecureCommand.new(self) unless secure?
  end

  private

  PDFTEX_BINARIES   = %w(pdflatex pdftex)
  CONVERT_BINARIES  = %w(convert)
  INSECURE_COMMANDS = %w(\\input \\write \\include)
  PDFTEX_OPTIONS    = %w(-interaction=nonstopmode)
  CONVERT_OPTIONS   = %w(-density 300 -quality 90)
  private_constant :INSECURE_COMMANDS, :PDFTEX_BINARIES, :PDFTEX_OPTIONS,
                   :CONVERT_OPTIONS

  def sanitized_equation
    equation.gsub '$', '\\$'
  end

  def wrapped_equation
    <<-LATEX.chomp.strip
\\documentclass[preview]{standalone}
\\begin{document}
$#{sanitized_equation}$
\\end{document}
    LATEX
  end

  def ident
    Digest::MD5.hexdigest equation
  end

  def key
    "images/#{ident}.png"
  end

  def pdftex
    pdftex = PDFTEX_BINARIES.detect { |b| system 'which', b }
    raise BinaryNotInstalled.new(self, 'pdftex') unless pdftex
    return pdftex
  end

  def convert
    convert = CONVERT_BINARIES.detect { |b| system 'which', b }
    raise BinaryNotInstalled.new(self, 'convert') unless convert
    return convert
  end

  # @abstract
  #
  # Generic error class for all LaTeX errors.

  class Error < StandardError
    # @return [LaTeX] The LaTeX equation.
    attr_reader :latex

    # @private
    def initialize(msg, latex)
      super msg
      @latex = latex
    end
  end

  # Raised when a LaTeX equation includes insecure commands.

  class InsecureCommand < Error
    # @private
    def initialize(latex)
      super "Insecure LaTeX equation", latex
    end
  end

  # Raised when required binaries are not found.

  class BinaryNotInstalled < Error
    # @return [String] The binary that wasn't found.
    attr_reader :binary

    # @private
    def initialize(latex, binary)
      super "#{binary} not found", latex
      @binary = binary
    end
  end

  # Raised when pdftex fails to complete successfully.

  class PDFConversionFailed < Error
    # @private
    def initialize(latex)
      super "pdftex conversion failed", latex
    end
  end

  # Raised when convert fails to complete successfully.

  class PNGConversionFailed < Error
    # @private
    def initialize(latex)
      super "ImageMagick PNG conversion failed", latex
    end
  end
end
