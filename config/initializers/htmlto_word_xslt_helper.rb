# frozen_string_literal: true

# This helper method xslt_path prepends the htmltoword method,
# to allow us to overide the numbering.xslt styleheet with one
# with fix in https://github.com/karnov/htmltoword/issues/73
# We applied this gem gem htmltoword-1.1.0.

module Htmltoword

  module XSLTHelper

    def xslt_path(template_name)
      if template_name == "numbering"
        File.join(Rails.root.join("app", "assets", "xslt", "htmltoword"), "#{template_name}.xslt")
      else
        File.join(Htmltoword.config.default_xslt_path, "#{template_name}.xslt")
      end
    end

  end

end
