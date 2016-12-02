# Asynchronously posts a message to Slack that impersonates a user, making it
# appear as if the user typed that message.

class EchoJob < ApplicationJob
  queue_as :default

  # Posts a text message to Slack, impersonating a user.
  #
  # @param [Hash] command The originating Slack command, from
  #   {Slack::Command}#to_h. The name and icon of the user is obtained from this
  #   object.
  # @param [String] text The text message.

  def perform(command, text)
    Slack.instance.echo Slack::Command.new(command), text: text
  end
end
