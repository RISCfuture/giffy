# Controller for the `/giffy` command.

class GiffyController < ApplicationController
  before_action :validate_command
  report_errors_to_slack

  # Runs when `/giffy` is invoked. `params[:text]` contains the search query.
  # Searches Google Images for an animated GIF matching the query, and chooses
  # one at random. Posts the URL to Slack, which automatically loads and
  # displays the image. The actual work is handled by {GifSearchJob}.

  def search
    GifSearchJob.perform_later command.to_h,
                               params[:text],
                               view_context.image_url('giffy.png')
    head :ok
  end
end
