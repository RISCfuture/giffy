require 'slack'

# An OAuth access token for use with a Slack team that has authorized Giffy.
# This record can be used to interact with the Slack API as an authenticated
# user for that team.
#
# Associations
# ------------
#
# |                         |                                                                 |
# |:------------------------|:----------------------------------------------------------------|
# | `authorization_request` | The {AuthorizationRequest} that resulted in this authorization. |
# | `gif_results`           | The {GIFResult GIFResults} created for this team.               |
#
# Properties
# ----------
#
# |                               |                                                                     |
# |:------------------------------|:--------------------------------------------------------------------|
# | `access_token`                | The access token for use with the Slack API.                        |
# | `team_name`                   | The name of the Slack team.                                         |
# | `team_id`                     | The unique Slack ID of the team.                                    |
# | `incoming_webhook_url`        | The URL to post to when sending incoming webhook commands.          |
# | `incoming_webhook_channel`    | The Slack ID of the channel the incoming webhook is configured for. |
# | `incoming_webhook_config_url` | The URL that admins should use to configure the incoming webhook.   |

class Authorization < ApplicationRecord
  has_one :authorization_request, dependent: :destroy, inverse_of: :authorization
  has_many :gif_results, dependent: :delete_all, inverse_of: :authorization

  validates :access_token, :scope,
            presence: true,
            length:   {maximum: 128}
  validates :team_name,
            length:    {maximum: 128},
            allow_nil: true
  validates :team_id,
            presence:   true,
            length:     {maximum: 20},
            uniqueness: true
  validates :incoming_webhook_url, :incoming_webhook_config_url,
            url:       true,
            allow_nil: true
  validates :incoming_webhook_channel,
            length:    {maximum: 128},
            allow_nil: true

  # Revokes the access token and deletes this record.

  def revoke!
    response = Slack.instance.api_command('auth.revoke', token: access_token)
    raise "Couldn't revoke token: #{response['error']}" unless response['ok'] && response['revoked']

    destroy
  end

  # Calls {Slack#api_command}, providing the access token.
  #
  # @param [String] command The Slack API command, such as "chat.postMessage".
  # @param [Hash<Symbol,String>] options Options for that API command (see the
  #   Slack API documentation).

  def api_command(command, options={})
    Slack.instance.api_command command, options.merge(token: access_token)
  end
end
