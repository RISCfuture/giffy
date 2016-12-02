require 'google'
require 'slack'

# Asynchronous job for `/giffy`. See {GiffyController}.

class GifSearchJob < ApplicationJob
  queue_as :default

  # Searches for a GIF using Google Image Search and posts it to the channel.
  #
  # @param [Hash<Symbol, String>] command The originating Slack command,
  #   obtained using {Slack::Command}#to_h. This object is used to determine the
  #   channel to post to.
  # @param [String] text The search query.
  # @param [String] giffy_image The Giffy image to use as the avatar in Slack.

  def perform(command, text, giffy_image)
    command = Slack::Command.new(command)
    Slack.instance.echo command

    images = Google.instance.image_search(text)

    if images.empty?
      Slack.instance.webhook_message command.channel_id, I18n.t('controllers.giffy.search.no_results').sample
      return
    end

    num   = [1.0/rand, images.size - 1].min
    image = images[num.to_i]
    Slack.instance.webhook_message command.channel_id, image, icon_url: giffy_image
  end
end
