# Extends ActionController to include a {#current_template} attribute.
#
# @!attribute current_template
#   @return [String] The name of the template being rendered.

module CurrentTemplate
  extend ActiveSupport::Concern

  included do
    attr_reader :current_template
    helper_method :current_template
  end

  # @private
  def _render_template(options, *other_stuff)
    @current_template = options[:template]
    super
  end
end
