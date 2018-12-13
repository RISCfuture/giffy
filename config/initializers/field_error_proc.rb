# Change the behavior of fields with bad data. This adds a data-errors
# attribute to the tag with the errors. JavaScript then creates the appropriate
# visual error display.

ActionView::Base.field_error_proc = proc do |html_tag, instance|
  if html_tag.start_with?('<label')
    html_tag
  else
    tag                = Nokogiri::HTML.fragment(html_tag).children.first
    tag['data-errors'] = instance.error_message.to_json
    tag.to_html.html_safe
  end
end
