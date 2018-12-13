require 'comic_sans'

# Comic Sans image generation job for use with the `/comicsans` command.
#
# @see ComicSansController#display

class ComicSansJob < SlackCommandJob
  queue_as :default

  protected

  # Uses Prawn to generate an image of some text in Comic Sans, then uploads it
  # to S3 and posts the URL to the Slack channel.
  #
  # @param [Slack::Command] command The original Slack command. This object is
  #   used to retrieve the text to display in Comic Sans.

  def perform_command(command)
    string= ComicSans.new(command.text)
    string.upload

    command.reply response_type: 'in_channel',
                  text:          I18n.t('jobs.comicsans.text', user: command.user_name),
                  attachments:   [{
                      fallback:  command.text,
                      image_url: string.url.to_s
                  }]
  end
end
