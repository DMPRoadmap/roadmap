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

  # Generate a direct plan creation link based on provided template
  # @param template [Template] template used for plan creation
  # @param hidden [Boolean] should the link be hidden?
  # @param text [String] text for the link
  # @param id [String] id for the link element
  def direct_link(template, hidden = false, text = nil, id = nil)
    params = {
      org: { id: current_user&.org&.id },
      funder: { id: template.org&.id },
      template_id: template.id
    }
    cls = text.nil? ? "direct-link" : "direct-link btn btn-default"
    style = hidden ? "display: none" : ""

    link_to(plans_url(plan: params), method: :post, title: _("Create plan"),
                                     class: cls, id: id, style: style) do
      if text.nil?
        "<span class=\"fa fa-plus-square\"></span>".html_safe
      else
        text.html_safe
      end
    end
  end
end
