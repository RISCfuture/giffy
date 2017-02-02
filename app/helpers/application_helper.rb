# Methods in this module are available to all views in the application.

module ApplicationHelper

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
end
