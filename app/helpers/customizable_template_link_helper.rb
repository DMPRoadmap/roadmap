# frozen_string_literal: true

# Helper methods for generating links for customizing templates
module CustomizableTemplateLinkHelper
  # Link to the appropriate customizable template.
  # Default link name set if name not set which can be overwritten.
  # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
  def link_to_customizable_template(name, customization, template, css_classes='')
    name = nil unless name.present?

    if customization.present?
      if customization.created_at < template.created_at
        name = name.blank? ? _('Transfer customisation') : name
        link_to name,
                org_admin_template_customization_transfers_path(customization.id),
                data: { method: 'post' },
                class: css_classes
      else
        name = name.blank? ? _('Edit customisation') : name
        link_to name, org_admin_template_path(id: customization.id), class: css_classes
      end
    else
      name = name.blank? ? _('Customise') : name
      link_to name,
              org_admin_template_customizations_path(template.id),
              'data-method': 'post',
              class: css_classes
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity
end
