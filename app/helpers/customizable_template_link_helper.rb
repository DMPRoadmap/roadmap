# frozen_string_literal: true

# Helper methods for generating links for customizing templates
module CustomizableTemplateLinkHelper
  # Link to the appropriate customizable template.
  # Default link name set if name not set which can be overwritten.
  # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
  # rubocop:todo Metrics/CyclomaticComplexity
  def link_to_customizable_template(name, customization, template, dropdown)
    name = nil unless name.present?
    link_css = dropdown ? 'dropdown-item px-3' : 'px-3'

    if customization.present?

      if customization.created_at < template.created_at
        name = _('Transfer customisation') if name.blank?
        link_to name,
                org_admin_template_customization_transfers_path(customization.id),
                data: { method: 'post' },
                class: link_css
      else
        name = _('Edit customisation') if name.blank?
        link_to name, org_admin_template_path(id: customization.id), class: link_css
      end
    else
      name = _('Customise') if name.blank?
      link_to name,
              org_admin_template_customizations_path(template.id),
              'data-method': 'post',
              class: link_css
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity
end
