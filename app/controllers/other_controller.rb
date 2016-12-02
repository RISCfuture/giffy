# Other small commands.

class OtherController < ApplicationController
  GLARE_EMOTICON = 'ಠ_ಠ'.freeze

  before_action :validate_command
  report_errors_to_slack

  # Runs when `/glare` is invoked. Prepends the glare emoticon to a message.

  def glare
    text = [GLARE_EMOTICON, command.text].select(&:present?).join(' ')
    EchoJob.perform_later command.to_h, text
    head :ok
  end

  # Runs when `/spagott` is invoked. Displays the "Spagott" image.

  def spagott
    EchoJob.perform_later command.to_h, view_context.image_url('spagott.jpg')
    head :ok
  end
end
