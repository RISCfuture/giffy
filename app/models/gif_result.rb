require 'slack'

# An instance of `/giffy` being invoked and a result being returned. Contextual
# information about this event is recorded to the database so the messsage can
# be updated or removed later as appropriate.
#
# Associations
# ------------
#
# |                 |                                                       |
# |:----------------|:------------------------------------------------------|
# | `authorization` | The {Authorization} used to post the `/giffy` result. |
#
# Properties
#
# |                |                                                                                               |
# |:---------------|:----------------------------------------------------------------------------------------------|
# | `channel_id`   | The Slack ID of the channel that the GIF was posted to.                                       |
# | `user_id`      | The Slack ID of the user that requested the GIF.                                              |
# | `user_name`    | The username of the user that requested the GIF.                                              |
# | `query`        | The search query provided by the user.                                                        |
# | `image_url`    | The GIF URL chosen by Giffy.                                                                  |
# | `response_url` | The URL provided by Slack to use when making updates to the slash command's response message. |
# | `noped`        | Set to `true` when the user clicks the "NopeNopeNope" button.                                 |

class GIFResult < ApplicationRecord
  belongs_to :authorization, inverse_of: :gif_results

  validates :channel_id, :user_id, :user_name,
            presence: true,
            length:   {maximum: 64}
  validates :query, :image_url, :response_url,
            presence: true,
            length:   {maximum: 255}

  after_create :spawn_button_removal_job

  # You can pass a Slack::Command instance as a short-hand to set multiple
  # properties of this GIFResult.
  #
  # @param [Slack::Command] command Slack command invocation context to use as a
  #   template for configuring this instance.

  def command=(command)
    @command           = command
    self.authorization = command.authorization
    self.channel_id    = command.channel_id
    self.user_id       = command.user_id
    self.user_name     = command.user_name
    self.query         = command.text
    self.response_url  = command.response_url
  end

  private

  def spawn_button_removal_job
    GIFButtonRemoverJob.set(wait_until: 10.minutes.from_now).perform_later(self)
  end
end
