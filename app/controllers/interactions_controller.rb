# Endpoint for action buttons associated with Slack commands. Slack calls the
# {#handle} action when one of these action buttons is pressed.

class InteractionsController < ApplicationController

  # Invoked when a Slack message's action button is pressed. Dispatches to the
  # appropriate handler and responds with 200 OK.
  #
  # Routes
  #
  # * `POST /interact`
  #
  # Body Parameters
  # ---------------
  #
  # |           |                                                                                     |
  # |:----------|:------------------------------------------------------------------------------------|
  # | `payload` | JSON-serialized dictionary of data. See https://api.slack.com/docs/message-buttons. |

  def handle
    payload = JSON.parse(params[:payload])

    if payload['token'] != Giffy::Configuration.slack.verification_token
      render status: :unauthorized, body: t('controllers.application.validate_command.invalid')
      return
    end

    case payload['actions'].first['name']
      when 'audit_gif'
        audit_gif payload
      else
        return head(:unprocessable_entity)
    end
  end

  protected

  # Handles the action button on a `/giffy` response. Spawns a
  # {MessageDeleteJob}.
  #
  # @param [Hash] payload The Slack-provided interaction payload.

  def audit_gif(payload)
    case payload['actions'].first['value']
      when 'delete'
        MessageDeleteJob.perform_later payload
        head :ok
      else
        head :unprocessable_entity
    end
  end
end
