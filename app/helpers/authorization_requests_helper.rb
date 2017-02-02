require 'addressable/template'

# Helper methods for views of {AuthorizationRequestsController}.

module AuthorizationRequestsHelper

  # @return [Addressable::URI] The URL to use to begin the OAuth 2.0
  #   authorization process (with an "Add to Slack" button).

  def oauth_url
    @@oauth_url_template ||= Addressable::Template.new(Giffy::Configuration.slack.oauth_url_template)
    @@oauth_url_template.expand 'query' => {
        'scope'     => Giffy::Configuration.slack.scopes.join(','),
        'client_id' => Giffy::Configuration.slack.client_id
    }
  end

  # Given an OAuth authorization error identifier from Slack, returns a
  # human-readable description of that error. Returns the identifier if the
  # error identifier is unknown.
  #
  # @param [String] error The Slack error identifier (such as "invalid_token").
  # @return [String] A localized, human-readable description of the error.

  def error_message(error)
    t "views.authorization_requests.create.error_message.#{error}",
      default: t('views.authorization_requests.create.error_message.default', error: error)
  end

  # Given an authorization request, returns JSON information about the request
  # in a schema matching that expected by the Vue.js status widget.
  #
  # For Ajax polling, the {AuthorizationRequestsController#show} JBuilder
  # template is normally used, but if the request could not be saved (and thus
  # doesn't have an ID, this method is used instead.)
  #
  # @param [AuthorizationRequest] request The authorization request.
  # @return [String] The JSON representation.

  def request_json(request)
    if request.valid?
      {id: request.id, status: request.status, error: request.error}
    else
      {id: nil, status: 'error', error: request.errors.full_messages.to_sentence}
    end.to_json
  end
  #TODO don't duplicate this code between here and the show template
end
