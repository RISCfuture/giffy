# Deletes a message sent by Giffy.

class MessageDeleteJob < ApplicationJob
  queue_as :default

  # Deletes a message.
  #
  # @param [Hash] payload The Slack-provided interaction payload.

  def perform(payload)
    gif_result    = GIFResult.find_by_id(payload['callback_id'])
    authorization = gif_result&.authorization || Authorization.find_by_team_id!(payload['team']['id'])
    authorization.api_command 'chat.delete',
                              ts:      payload['message_ts'],
                              channel: gif_result&.channel_id || payload['channel']['id']
  rescue Slack::Error
    # if we can't delete it, try "deleting" it by replacing it with a benign message
    url  = Addressable::URI.parse(gif_result&.response_url || payload['response_url'])
    body = {text:             I18n.t('jobs.message_delete.error'),
            replace_original: true,
            attachments:      []}
    Slack.instance.send :callback_post, url, body
  ensure
    gif_result&.update_attribute :noped, true
  end
end
