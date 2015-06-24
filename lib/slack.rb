require 'addressable/uri'

class Slack
  include Singleton

  # Simulates a slash-command echo by temporarily impersonating a user and
  # posting the command they just sent.
  #
  # @param [Slack::Command] command Command information used to impersonate the
  #   user and post the echo message.
  # @return [Hash] The response from Slack.
  # @raise [Slack::InvalidResponseError] If the API call is unsuccessful.

  def echo(command, text: nil)
    userinfo  = User.load(command.user_id)
    user_icon = userinfo['user']['profile']['image_48']
    username  = userinfo['user']['profile']['real_name'] || userinfo['user']['name']
    webhook_post webhook_message_url,
                 text:     (text || "#{command.command} #{command.text}").strip,
                 channel:  command.channel_id,
                 username: username,
                 icon_url: user_icon
  end

  # Loads user information from Slack. Used by the {User} class to cache user
  # information.
  #
  # @param [String] user_id The Slack-assigned user ID (not username).
  # @return [Hash] User information returned by Slack.
  # @raise [Slack::InvalidResponseError] If the API call is unsuccessful.

  def user_info(user_id)
    post user_info_url, user: user_id
  end

  # Posts a message to a Slack channel. This uses the `chat.postMessage` API,
  # which has limitations; namely, it can only post to channels that `@tim` is a
  # member of, or that are public.
  #
  # @param [String] recipient The channel name or ID.
  # @param [String] message The message to post.
  # @param [String] username The username the bot should appear as.
  # @param [String] icon_url The URL to an image that should be the bot's
  #   avatar.
  # @param [String] icon_emoji The name of an emoji (such as ":pizza:") that
  #   should be the bot's avatar. Takes precedence over `icon_url`.
  # @return [Hash] The response from Slack.
  # @raise [Slack::InvalidResponseError] If the API call is unsuccessful.

  def message(recipient, message, username: 'Giffy', icon_url: nil, icon_emoji: nil)
    post message_url,
         text:       message,
         channel:    recipient,
         username:   username,
         icon_url:   icon_url,
         icon_emoji: icon_emoji
  end

  # Posts a message to a Slack channel. This uses the Incoming Webhooks API,
  # which can post to any channel from which a slash-command is received.
  #
  # @param [String] recipient The channel name or ID.
  # @param [String] message The message to post.
  # @param [String] username The username the bot should appear as.
  # @param [String] icon_url The URL to an image that should be the bot's
  #   avatar.
  # @param [String] icon_emoji The name of an emoji (such as ":pizza:") that
  #   should be the bot's avatar. Takes precedence over `icon_url`.
  # @return [Hash] The response from Slack.
  # @raise [Slack::InvalidResponseError] If the API call is unsuccessful.

  def webhook_message(recipient, message, username: 'Giffy', icon_url: nil, icon_emoji: nil, attachments: nil)
    webhook_post webhook_message_url,
                 text:        message,
                 channel:     recipient,
                 username:    username,
                 icon_url:    icon_url,
                 icon_emoji:  icon_emoji,
                 attachments: attachments
  end

  private

  def user_info_url
    @user_info_url ||= Addressable::URI.parse(Giffy::Configuration.slack.user_info_url)
  end

  def message_url
    @message_url ||= Addressable::URI.parse(Giffy::Configuration.slack.message_url)
  end

  def webhook_message_url
    @webhook_message_url ||= Addressable::URI.parse(Giffy::Configuration.slack.webhook_message_url)
  end

  def post(url, body)
    @conn        ||= Faraday.new(url: url.origin)
    body[:token] = Giffy::Configuration.slack.api_token
    resp         = @conn.post do |request|
      request.url url.request_uri
      request.body = body
    end

    raise InvalidResponseError, "Invalid response from Slack: #{resp.status}" if resp.status/100 != 2

    parsed_body = JSON.parse(resp.body)
    raise InvalidResponseError, "Invalid response from Slack: #{parsed_body['error']}" unless parsed_body['ok']

    return parsed_body
  end

  def webhook_post(url, body)
    @wconn ||= Faraday.new(url: url.origin)
    resp   = @wconn.post do |request|
      request.url url.request_uri
      request.body = body.to_json
    end

    raise InvalidResponseError, "Invalid response from Slack: #{resp.status}" if resp.status/100 != 2
    return resp.body
  end

  # Raised when the Slack API returns an error.

  class InvalidResponseError < StandardError
  end

  # Object containing data about a slash-command invocation. See the Slack API
  # to learn about its fields: https://api.slack.com/slash-commands

  class Command < Struct.new(:token, :team_id, :team_domain, :channel_id, :channel_name, :user_id, :user_name, :command, :text)

    # @return [Hash] Information about the user, using the {User} model.

    def user_info!
      User.load(user_id)
    end

    # @return [true, false] Whether the given token matches the valid command
    #   token stored in `config/environments/common/slack.yml`.

    def valid?
      token == Giffy::Configuration.slack.command_tokens[command.sub(/^\//, '')]
    end
  end
end
