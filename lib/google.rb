require 'addressable/template'
require 'addressable/uri'

# Helper class for integrating with the Google API.

class Google
  include Singleton

  # Performs a Google image search with SafeSearch on high and filter set to
  # animated GIFs only.
  #
  # @param [String] query The search query.
  # @param [String] ip The originating IP, to reduce the possibility of rate
  #   limiting.
  # @return [Array<Hash>] A list of results from Google. See the Google image
  #   search API for more information.
  # @raise [Google::InvalidResponseError] If the API request fails.

  def image_search(query, ip=nil)
    url      = image_search_url(query)
    @conn    ||= Faraday.new(url: url.origin)
    response = @conn.get do |request|
      request.url url.request_uri
      request.headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11) AppleWebKit/601.1.56 (KHTML, like Gecko) Version/9.0 Safari/601.1.56'
    end

    raise InvalidResponseError, "Invalid response from Google: #{response.status}" if response.status/100 != 2

    html = Nokogiri::HTML(response.body)
    html.css('div.rg_meta').map do |meta|
      begin
        JSON.parse(meta.content)['ou']
      rescue
        nil
      end
    end.compact
  end

  private

  def image_search_template
    @image_search_template ||= Addressable::Template.new(Giffy::Configuration.google.image_search_url_template)
  end

  def image_search_url(query)
    image_search_template.expand(query: {
        as_st:  'y',
        tbm:    'isch',
        as_q:   query,
        tbs:    'itp:animated',
        gws_rd: 'ssl'
    })
  end

  # Raised when a Google API request fails.

  class InvalidResponseError < StandardError
  end
end
