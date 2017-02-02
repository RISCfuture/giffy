require 'google'
require 'slack'

# Asynchronous job for `/giffy`.
#
# @see GiffyController#search

class GIFSearchJob < SlackCommandJob
  queue_as :default

  protected

  # Searches for a GIF using Google Image Search and posts it to the channel.
  #
  # @param [Slack::Command] command The originating Slack command. This object
  #   is used to determine the channel to post to and GIF to search for.

  def perform_command(command)
    image = find_gif(command)
    unless image
      send_empty_reply(command)
      return
    end

    send_reply command, image
  end

  private

  def find_gif(command)
    images = Google.instance.image_search(command.text)
    return nil if images.empty?

    num = [1.0/rand, images.size - 1].min
    return images[num.to_i]
  end

  def send_reply(command, image)
    command.reply response_type: 'in_channel',
                  text:          I18n.t('jobs.gif_search.text', user: command.user_name, query: command.text),
                  attachments:   [{
                                      image_url:       image,
                                      attachment_type: 'default',
                                      fallback:        I18n.t('jobs.gif_search.fallback'),
                                      callback_id:     'TODO'
                                  }]
  end

  def send_empty_reply(command)
    command.reply text:          I18n.t('controllers.giffy.search.no_results').sample,
                  response_type: 'in_channel'
  end
end
