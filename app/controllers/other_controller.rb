# Other small commands.

class OtherController < ApplicationController
  GLARE_EMOTICON = 'ಠ_ಠ'.freeze

  before_action :validate_command
  report_errors_to_slack

  # Prepends the glare emoticon to a message.

  def glare
    text = [ GLARE_EMOTICON, command.text ].select(&:present?).join(' ')
    Slack.instance.echo command, text: text
    head :ok
  end

  # Displays the "Spagott" image.

  def spagott
    Slack.instance.echo command, text: view_context.image_url('spagott.jpg')
    head :ok
  end
end
