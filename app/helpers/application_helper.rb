require 'addressable/template'

# Methods in this module are available to all views in the application.

module ApplicationHelper
  extend self

  # @return [String] Same as `controller_name`, but prepends module names as a
  #   dash-delimited prefix.
  # @example
  #   # (in Foo::BarBazController)
  #   full_controller_name #=> "foo-bar_baz"

  def full_controller_name
    full_controller_path.gsub('/', '-')
  end

  # @return [String] The controller's path under `app/controllers`, and without
  #   the `_controller` suffix.
  # @example
  #   # (in Foo::BarBazController)
  #   full_controller_path #=> "foo/bar_baz"

  def full_controller_path
    controller.class.to_s.underscore.gsub(/_controller$/, '')
  end

  # @return [Addressable::URI] The URL to use to begin the OAuth 2.0
  #   authorization process (with an "Add to Slack" button).

  def oauth_url
    @@oauth_url_template ||= Addressable::Template.new(Giffy::Configuration.slack.oauth_url_template)
    @@oauth_url_template.expand 'query' => {
        'scope'     => Giffy::Configuration.slack.scopes.join(','),
        'client_id' => Giffy::Configuration.slack.client_id
    }
  end
end
