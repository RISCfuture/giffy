# Semi-RESTful controller for creating
# {AuthorizationRequest AuthorizationRequests}. This controller displays the
# "Add to Slack" page and manages the OAuth 2.0 authorization flow.
#
# The OAuth 2.0 flow proceeds as follows:
#
# 1. User visits {#new} page.
# 2. User clicks "Add to Slack", which redirects them to a Slack page with this
#    app's client ID.
# 3. User logs in and approves this app, and Slack redirects to the {#create}
#    action with an approval code.
# 4. An {AuthorizationRequest} is created with that approval code, and an
#    {AuthorizeJob} is spawned to receive an access token from Slack.
# 5. Meanwhile, the {#create} view polls the {#show} action repeatedly for
#    updates.
# 6. Once the access token is received, an {Authorization} is created with the
#    access token.
# 7. The {#create} front-end is updated with a success message.

class AuthorizationRequestsController < ApplicationController
  before_action :find_authorization_request, only: :show

  # Displays a landing page with an overview of the slash commands and an "Add
  # to Slack" button that commences the OAuth authorization flow.
  #
  # Routes
  # ------
  #
  # * `GET /`

  def new
    @error                 = params[:error].presence
    @authorization_request = AuthorizationRequest.find(params[:authorization_request_id]) if params[:authorization_request_id].present?

    respond_to do |format|
      format.html # new.html.slim
    end
  end

  # Redirect destination once the user has logged in to Slack and approved the
  # OAuth request. Receives a code from Slack which is used to generate an
  # access token. (This is done automatically by hooks in
  # {AuthorizationRequest}).
  #
  # If the `error` parameter is set, the `create_error` view is rendered
  # instead, and the error is localized if possible.
  #
  # Otherwise, the `create` view is rendered, including a Vue.js widget that
  # polls the {#show} action until the authorization is successful.
  #
  # Routes
  # ------
  #
  # * `GET /authorize`
  #
  # Query Parameters
  #
  # |         |                                                                                                             |
  # |:--------|:------------------------------------------------------------------------------------------------------------|
  # | `code`  | The authorization request code given by Slack.                                                              |
  # | `error` | If Slack was unable to complete the authorization, this parameter will contain an identifier for the error. |

  def create
    if params[:error].present?
      return redirect_to(root_url(error: params[:error]))
    end

    @authorization_request = AuthorizationRequest.create(code: params[:code])
    if @authorization_request.valid?
      redirect_to root_url(authorization_request_id: @authorization_request)
    else
      redirect_to root_url(error: 'invalid_authorization_request')
    end
  end

  # JSON endpoint returning an AuthorizationRequest's current status. The
  # {#create} view polls this endpoint to update the user once the authorization
  # flow is complete. The response schema exactly matches that of the Vue.js
  # widget's expectations, allowing the response to be dropped right into the
  # widget.
  #
  # Routes
  # ------
  #
  # * `GET /authorization_requests/:id.json`
  #
  # Path Parameters
  # ---------------
  #
  # |      |                                      |
  # |:-----|:-------------------------------------|
  # | `id` | The ID of an {AuthorizationRequest}. |

  def show
    respond_to do |format|
      format.json # show.json.jbuilder
    end
  end

  private

  def find_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:id])
  end
end
