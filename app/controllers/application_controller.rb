require 'slack'

# @abstract
#
# Abstract superclass for all controllers.
#
# By default, controllers do not verify the source of slash-command requests.
# You should use the {#validate_command} `before_action` if you want to do this.

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :null_session

  protected

  # Call this method in your controller to avoid having slack print out long
  # HTML error pages when an exception is raised. Instead, a brief error message
  # will be returned as the response, which will be displayed in Slack.

  def self.report_errors_to_slack
    rescue_from(Exception) do |error|
      render status: :internal_server_error, body: "An internal error occurred: #{error.to_s}"
      raise error
    end
  end

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
        params[:text]
    )
  end

  # `before_action` that verifies that the request came from a trusted source
  # (i.e., Slack itself and not an impostor).

  def validate_command
    if command.valid?
      return true
    else
      render status: :unauthorized, body: t('controllers.application.validate_command.invalid')
      return false
    end
  end
end
