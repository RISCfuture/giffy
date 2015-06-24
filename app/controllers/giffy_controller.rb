require 'google'
require 'slack'

# Controller for the `/giffy` command.

class GiffyController < ApplicationController
  before_action :validate_command
  report_errors_to_slack

  # Run when `/giffy` is invoked. `params[:text]` contains the search query.
  # Searches Google Images for an animated GIF matching the query, and chooses
  # one at random. Posts the URL to Slack, which automatically loads and
  # displays the image.

  def search
    images = Google.instance.image_search(params[:text])
    if images.empty?
      render status: :not_found, body: t('controllers.giffy.search.no_results')
      return
    end

    num = [1.0/rand, images.size - 1].min
    image = images[num.to_i]

    Slack.instance.echo command
    Slack.instance.webhook_message command.channel_id, image, icon_url: view_context.image_url('giffy.png')

    head :ok
  end
end
