# Created when this app is authorized for a team by a user, and Slack provides a
# code to use to retrieve the access token. Stores the state of the
# authorization process. Once created, an {AuthorizeJob} is automatically
# spawned to begin the process. This job calls {#authorize!} to retrieve the
# access token and create the {Authorization}.
#
# For more information about the OAuth 2.0 authorization flow, see
# {file:README.md} and {AuthorizationRequestsController}.
#
# Associations
# ------------
#
# |                 |                                                                                    |
# |:----------------|:-----------------------------------------------------------------------------------|
# | `authorization` | Once the app is authorized, this association stores the resulting {Authorization}. |
#
# Properties
# ----------
#
# |          |                                                                                              |
# |:---------|:---------------------------------------------------------------------------------------------|
# | `code`   | The code provided by Slack as part of the OAuth flow, and used to retrieve the access token. |
# | `status` | Where in the authorization process this request currently is.                                |
# | `error`  | Any error identifier provided by the Slack API.                                              |

class AuthorizationRequest < ApplicationRecord
  enum status: %i(pending working success error)

  belongs_to :authorization, optional: true, inverse_of: :authorization_request

  validates :code,
            presence: true,
            length: {maximum: 128}

  after_create :spawn_job

  # Calls the "oauth.access" Slack API command, providing the code. Creates an
  # {Authorization} to store the resulting access token.

  def authorize!
    oauth_response = Slack.instance.api_command('oauth.access',
                                                client_id:     Giffy::Configuration.slack.client_id,
                                                client_secret: Giffy::Configuration.slack.client_secret,
                                                code:          code)

    unless oauth_response['ok']
      update! status: :error, error: (oauth_response['error'] || 'unknown_error')
      return
    end

    Authorization.where(team_id: oauth_response['team_id']).each(&:revoke!)
    create_authorization! access_token:                oauth_response['access_token'],
                          scope:                       oauth_response['scope'],
                          team_name:                   oauth_response['team_name'],
                          team_id:                     oauth_response['team_id'],
                          incoming_webhook_url:        oauth_response['incoming_webhook']['url'],
                          incoming_webhook_channel:    oauth_response['incoming_webhook']['channel'],
                          incoming_webhook_config_url: oauth_response['incoming_webhook']['configuration_url']
  end

  private

  def spawn_job
    AuthorizeJob.perform_later self
  end
end
