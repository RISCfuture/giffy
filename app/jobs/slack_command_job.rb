require 'slack'

# @abstract
#
# Abstract superclass for all slash-command processing jobs. This class:
#
# * automatically instantiates a {Slack::Command} instance for you.
#
# To use this class, implement the {#perform_command} method.

class SlackCommandJob < ApplicationJob
  # @private
  def perform(command, *args)
    command = Slack::Command.new(command)
    perform_command command, *args
  end

  protected

  # Processes the slash command. Use the `command` instance to interact with
  # the Slack API.
  #
  # @param [Slack::Command] command Contextual information about the Slack
  #   command.

  def perform_command(command, *args)
    raise NotImplementedError
  end
end
