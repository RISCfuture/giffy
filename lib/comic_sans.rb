require 'digest/md5'
require 'tempfile'
require 'addressable/template'

# Interface for rendering strings to images in Comic Sans and uploading them to
# AWS S3.
#
# @example
#   string= ComicSans.new("Hello, World!")
#   string.upload
#   puts string.url

class ComicSans
  attr_reader :string

  def initialize(string)
    @string = string
  end

  # Renders the string to a temporary .pdf file intended for display as a
  # borderless image.
  #
  # @yield [path] A block to run with the rendered .pdf file before it is
  #   deleted.
  # @yieldparam [String] path The path to the temporary .pdf file.

  def to_pdf_file
    Dir.mktmpdir(ident) do |output_directory|
      string   = self.string
      pdf_path = File.join(output_directory, ident + '.pdf')
      Prawn::Document.generate(pdf_path) do
        font_families.update 'ComicSans' => {normal: Rails.root.join('vendor', 'assets', 'fonts', 'ComicSans.ttf').to_s}
        font('ComicSans') { text string }
      end
      yield pdf_path
    end
  end

  # Renders the string to a temporary .png file intended for display as a
  # borderless image.
  #
  # @yield [path] A block to run with the rendered .png file before it is
  #   deleted.
  # @yieldparam [String] path The path to the temporary .png file.
  # @raise [ComicSans::PNGConversionFailed] If convert fails to complete.

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

  # @return [Addressable::URI] The URL to the uploaded string image on S3. This
  #   URL will only be valid after {#upload} has been called.

  def url
    @@url_template ||= Addressable::Template.new(Giffy::Configuration.aws.url_template)
    @@url_template.expand 'bucket' => Giffy::Configuration.aws.bucket,
                          'region' => Giffy::Configuration.aws.region,
                          'key'    => key
  end

  private

  CONVERT_BINARIES  = %w(convert)
  CONVERT_OPTIONS   = %w(-density 150 -quality 90 -trim)
  private_constant :CONVERT_BINARIES, :CONVERT_OPTIONS

  def convert
    convert = CONVERT_BINARIES.detect { |b| system 'which', b }
    raise BinaryNotInstalled.new(self, 'convert') unless convert
    return convert
  end

  def ident
    Digest::MD5.hexdigest string
  end

  def key
    "images/#{ident}.png"
  end

  # @abstract
  #
  # Generic error class for all ComicSans errors.

  class Error < StandardError
    # @return [LaTeX] The LaTeX equation.
    attr_reader :latex

    # @private
    def initialize(msg, latex)
      super msg
      @latex = latex
    end
  end

  # Raised when convert fails to complete successfully.

  class PNGConversionFailed < Error
    # @private
    def initialize(latex)
      super "ImageMagick PNG conversion failed", latex
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
end
