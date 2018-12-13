# Removes the action buttons from a `/giffy` response. This job is run after the
# message has been displayed for a while.

class GIFButtonRemoverJob < ApplicationJob
  queue_as :default

  # Removes the action buttons from a `/giffy` response.
  #
  # @param [GIFResult] gif_result The context for the original `/giffy` command.

  def perform(gif_result)
    url  = Addressable::URI.parse(gif_result.response_url)
    body = {response_type:    'in_channel',
            replace_original: true,
            text:             I18n.t('jobs.gif_search.text', user: gif_result.user_name, query: gif_result.query),
            attachments:      [{
                image_url:       gif_result.image_url,
                attachment_type: 'default',
                fallback:        I18n.t('jobs.gif_search.fallback'),
                callback_id:     gif_result.id,
                actions:         []
            }]}
    Slack.instance.send :callback_post, url, body
  end
end
