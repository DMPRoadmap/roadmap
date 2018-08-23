# frozen_string_literal: true

# This module holds helper controller methods for controllers that deal with Templates
#
module TemplateMethods

  private

  def template_type(template)
    template.customization_of.present? ? _("customisation") : _("template")
  end

end
