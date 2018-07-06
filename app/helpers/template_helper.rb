# frozen_string_literal: true

module TemplateHelper

  def template_details_path(template)
    if template_modifiable?(template)
      edit_org_admin_template_path(template)
    else
      if template.persisted?
        org_admin_template_path(template)
      else
        org_admin_templates_path
      end
    end
  end

  # Is this Template modifiable?
  #
  # template - A Template object
  #
  # Returns Boolean
  def template_modifiable?(template)
    template.latest? &&
      template.customization_of.blank? &&
      template.id.present? &&
      template.org_id = current_user.org.id
  end

  def links_to_a_elements(links, separator = ", ")
    a = links.map do |l|
      "<a href=\"#{l['link']}\">#{l['text']}</a>"
    end
    a.join(separator)
  end

  def direct_link(template)
    params = {
      org_id: template.org.id,
      funder_id: '-1',
      template_id: template.id,
    }

    link_to(plans_url(plan: params), method: :post, title: _('Create plan')) do
      '<span class="fa fa-plus-square"></span>'.html_safe
    end
  end
end
