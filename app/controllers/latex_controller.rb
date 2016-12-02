require 'slack'
require 'digest/md5'
require 'tempfile'

# Controller for the `/latex` command.

class LatexController < ApplicationController
  before_action :validate_command
  report_errors_to_slack

  # Runs when `/latex` is invoked. `params[:text]` contains the LaTeX code,
  # which is checked for security and then given to {LatexJob} for processing.
  # LatexJob generates and uploads the image, and posts it to Slack.

  def display
    check_security command.text
    LatexJob.perform_later command.to_h

    head :ok
  end

  private

  def check_security(latex)
    raise LaTeXError, "Insecure LaTeX command" if %w(\\input \\write \\include).any? { |cmd| latex.include?(cmd) }
  end
end
