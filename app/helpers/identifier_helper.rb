# frozen_string_literal: true

module IdentifierHelper

  def id_for_display(id:, with_scheme_name: true)
    return _("None defined") if id.new_record? || id.value.blank?

    without = id.value_without_scheme_prefix
    prefix = with_scheme_name ? id.identifier_scheme.description + ": " : ""
    return prefix + id.value unless without != id.value && !without.starts_with?("http")

    link_to "#{prefix} #{without}", id.value, class: "has-new-window-popup-info"
  end

end
