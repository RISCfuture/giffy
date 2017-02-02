require 'slack'

# @abstract
#
# Abstract superclass for all controllers that respond to Slack slash command.
# This controller
#
# * validates the verification token given with the request against the app's
#   verification token (ignoring the request if it doesn't match),
# * rescues from exceptions by returning a short string to be displayed on the
#   Slack client, and
# * makes available a {#command} method representing the slash command context.

class SlackCommandController < ApplicationController
  abstract!

  before_action :validate_command
  protect_from_forgery with: :null_session

  rescue_from(Exception) do |error|
    render status: :internal_server_error, body: "An internal error occurred: #{error.to_s}"
    raise error
  end

  protected

  # @return [Slack::Command] The object containing information about the
  #   slash-command that invoked this request.

  def command
    @command ||= Slack::Command.new(
        params[:token],
        params[:team_id],
        params[:team_domain],
        params[:channel_id],
        params[:channel_name],
        params[:user_id],
        params[:user_name],
        params[:command],
        params[:text],
        params[:response_url]
    )
  end

  private

  def validate_command
    if command.valid?
      return true
    else
      render status: :unauthorized, body: t('controllers.application.validate_command.invalid')
      return false
    end
  end
end
