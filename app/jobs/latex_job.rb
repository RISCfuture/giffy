require 'latex'

# LaTeX processing job for use with the `/latex` command.
#
# @see LaTeXController#display
# @see LaTeX

class LaTeXJob < SlackCommandJob
  queue_as :default

  protected

  # Uses latex to generate an image of an equation, then uploads it to S3 and
  # posts the URL to the Slack channel.
  #
  # @param [Slack::Command] command The original Slack command. This object is
  #   used to retrieve the LaTeX equation, impersonate the user, and post to the
  #   channel.

  def perform_command(command)
    latex = LaTeX.new(command.text)
    latex.upload

    command.reply response_type: 'in_channel',
                  text:          I18n.t('jobs.latex.text', user: command.user_name),
                  attachments:   [{
                                      fallback:  latex.equation,
                                      image_url: latex.url.to_s
                                  }]
  end
end
