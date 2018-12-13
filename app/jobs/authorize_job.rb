require 'slack'

# This job retrieves an access token from an authorization code, given to us by
# Slack and stored in an {AuthorizationRequest}. Once the access token is
# retrieved, an {Authorization} is created to store it. The `status` attribute
# of the request is also updated by this job.
#
# For more information on the OAuth 2.0 flow used by Slack, see {file:README.md}
# and {AuthorizationRequestsController}.

class AuthorizeJob < ApplicationJob
  queue_as :default

  # Authorizes a request and creates an Authorization.
  #
  # @param [AuthorizationRequest] request The authorization request.

  def perform(request)
    request.update_attribute :status, :working
    request.authorize!
    request.update_attribute :status, :success
  rescue Slack::Error => err
    request.update! status: :error, error: err.to_s
  rescue StandardError
    request.update_attribute :status, :pending
    raise
  end
end
