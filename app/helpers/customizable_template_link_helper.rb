# frozen_string_literal: true

# Helper methods for generating links for customizing templates
module CustomizableTemplateLinkHelper
  # Link to the appropriate customizable template.
  # Default link name set if name not set which can be overwritten.
  # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
  def link_to_customizable_template(name, customization, template)
    name = nil unless name.present?

    if customization.present?
      if customization.created_at < template.created_at
        name = _('Transfer customisation') if name.blank?
        link_to name,
                org_admin_template_customization_transfers_path(customization.id),
                data: { method: 'post' }
      else
        name = _('Edit customisation') if name.blank?
        link_to name, org_admin_template_path(id: customization.id)
      end
    else
      name = _('Customise') if name.blank?
      link_to name,
              org_admin_template_customizations_path(template.id),
              'data-method': 'post'
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity
end
