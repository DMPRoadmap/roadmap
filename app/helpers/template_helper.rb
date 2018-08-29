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

  def links_to_a_elements(links, separator = ', ')
    a = links.map do |l|
      "<a href=\"#{l['link']}\">#{l['text']}</a>"
    end
    a.join(separator)
  end
end