require 'addressable/uri'
require 'addressable/template'

class Slack
  include Singleton

  # Invokes a Slack API command.
  #
  # @param [String] command The Slack API command, such as "chat.postMessage".
  # @param [Hash<Symbol,String>] options Options for that API command (see the
  #   Slack API documentation).
  # @return [Hash] The API command response, de-serialized from JSON.
  # @raise [Slack::Error] If the response is not 200 OK or an error occurs.

  def api_command(command, options={})
    post api_url(command), options
  end

  private

  def api_url(command)
    @@api_url_template ||= Addressable::Template.new(Giffy::Configuration.slack.api_url_template)
    @@api_url_template.expand 'command' => command
  end

  def post(url, body)
    @conn ||= Faraday.new(url: url.origin) do |c|
      c.request :url_encoded
      c.response :detailed_logger if Rails.env.development?
      c.adapter Faraday.default_adapter
    end
    resp  = @conn.post do |request|
      request.url url.request_uri
      request.body = body
    end

    raise UnsuccessfulResponseError.new(url, body, resp) if resp.status/100 != 2

    parsed_body = JSON.parse(resp.body)
    raise APIError.new(url, body, resp) unless parsed_body['ok']

    return parsed_body
  end

  def callback_post(url, body)
    conn = Faraday.new(url: url.origin) do |c|
      c.response :detailed_logger if Rails.env.development?
      c.adapter Faraday.default_adapter
    end
    resp = conn.post do |request|
      request.url url.request_uri
      request.headers['Content-Type'] = 'application/json'
      request.body                    = body.to_json
    end

    raise UnsuccessfulResponseError.new(url, body, resp) if resp.status/100 != 2

    # sometimes the responses are JSON-encoded, sometimes they're not?!
    begin
      parsed_body = JSON.parse(resp.body)
      raise APIError.new(url, body, resp) unless parsed_body['ok']
      return parsed_body
    rescue JSON::ParserError
      raise CallbackError.new(url, body, resp) if resp.body != 'ok'
      return resp.body
    end

    return resp.body
  end

  # @abstract
  #
  # Raised when the Slack API returns an error.

  class Error < StandardError
    # @return [Addressable::URI] url The request URL.
    attr_reader :url
    # @return [Hash] body The request body prior to encoding.
    attr_reader :body
    # @return [Faraday::Response] The HTTP response.
    attr_reader :response

    # @private
    def initialize(msg, url, body, response)
      super(msg)
      @url      = url
      @body     = body
      @response = response
    end
  end

  # Raised when the Slack API returns a response code other than 200 OK.

  class UnsuccessfulResponseError < Error
    # @private
    def initialize(url, body, response)
      super "Invalid response from Slack: #{response.status}", url, body, response
    end
  end

  # Raised when the Slack API response includes an 'error' property.

  class APIError < Error
    # @return [String] The Slack error identifier.
    attr_reader :error

    # @private
    def initialize(url, body, response)
      @error = JSON.parse(response.body)['error']
      super "Slack API error: #{@error}", url, body, response
    end
  end

  # Raised when a Slack callback response is an error.

  class CallbackError < Error
    # @return [String] The Slack error identifier.
    attr_reader :error

    # @private
    def initialize(url, body, response)
      @error = response.body
      super "Slack API error: #{@error}", url, body, response
    end
  end

  # Object containing data about a slash-command invocation. See the Slack API
  # to learn about its fields: https://api.slack.com/slash-commands

  class Command < Struct.new(:token, :team_id, :team_domain, :channel_id, :channel_name, :user_id, :user_name, :command, :text, :response_url)

    # @overload initialize(token, team_id, team_domain, channel_id, channel_name, user_id, user_name, command, text)
    #  Creates a new command from the given parameters.
    # @overload initialize(hash)
    #  Creates a new command from the given hash.
    #  @param [Hash<Symbol, String>] hash Command attributes.

    def initialize(*args)
      if args.size == 1 && args.first.kind_of?(Hash)
        hsh = args.first.with_indifferent_access
        super *members.map { |m| hsh[m] }
      else
        super
      end
    end

    # @return [true, false] Whether the given token matches the valid command
    #   token stored in `config/environments/common/slack.yml`.

    def valid?
      token == Giffy::Configuration.slack.verification_token
    end

    # @return [Authorization] The OAuth authorization associated with this team.

    def authorization
      @authorization ||= Authorization.find_by_team_id!(team_id)
    end

    # Sends a message to Slack to be posted in response to this command. The
    # format of the body is similar to the "chat.postMessage" API action, but
    # with limitations. See "Delayed responses and multiple responses" under
    # https://api.slack.com/slash-commands#responding_to_a_command for more.
    #
    # @param [Hash<String, Object>] body The message body.
    # @raise [Slack::Error] If the response is not 200 OK or an error occurs.
    # @example
    #   command.reply text: "Hello, world!", in_channel: true

    def reply(body)
      url  = Addressable::URI.parse(response_url)
      resp = Slack.instance.send(:callback_post, url, body)
    end

    delegate :api_command, to: :authorization
  end
end
