# frozen_string_literal: true

# This is a fix for CVE-2020-5267 which isn't patched in Rails4 since it's out
# of lifetime support now

# TODO: remove this once we are Rails 5+

ActionView::Helpers::JavaScriptHelper::JS_ESCAPE_MAP.merge!(
  { "`": "\\`", "$": "\\$" }
)

module ActionView::Helpers::JavaScriptHelper

  alias :old_ej :escape_javascript
  alias :old_j :j

  # Monkey patch Rails' :escape_javascript method used in a few of our views
  def escape_javascript(javascript)
    javascript = javascript.to_s
    if javascript.empty?
      result = ""
    else
      result = javascript.gsub(/(\\|<\/|\r\n|\342\200\250|\342\200\251|[\n\r"']|[`]|[$])/u, JS_ESCAPE_MAP)
    end
    javascript.html_safe? ? result.html_safe : result
  end

  alias :j :escape_javascript

end
