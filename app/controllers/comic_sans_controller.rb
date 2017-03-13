require 'slack'

# Controller for the `/comicsans` command.

class ComicSansController < SlackCommandController

  # Runs when `/comicsans` is invoked. `params[:text]` contains the string to
  # display in Comic Sans. {ComicSansJob} generates and uploads the image, and
  # posts it to Slack.

  def display
    ComicSansJob.perform_later command.to_h
    head :ok
  end
end
