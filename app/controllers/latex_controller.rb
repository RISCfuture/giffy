require 'slack'
require 'latex'

# Controller for the `/latex` command.

class LaTeXController < SlackCommandController

  # Runs when `/latex` is invoked. `params[:text]` contains the LaTeX code,
  # which is checked for security and then given to {LaTeXJob} for processing.
  # LaTeXJob generates and uploads the image, and posts it to Slack.

  def display
    latex = LaTeX.new(command.text)
    latex.check_security!
    LaTeXJob.perform_later command.to_h

    head :ok
  end
end
