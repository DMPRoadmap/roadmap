module TemplateHelper
  def links_to_a_elements(links, separator = ', ')
    a = links.map do |l|
      "<a href=\"#{l['link']}\">#{l['text']}</a>"
    end
    a.join(separator)
  end

  def direct_link(template, hidden = false, text = nil)
    params = { org_id: template.org.id, funder_id: '-1', template_id: template.id }
    cls = text.nil? ? 'direct-link' : 'direct-link btn btn-default'
    style = hidden ? 'display: none' : ''

    link_to(plans_url(plan: params), method: :post, title: _('Create plan'), class: cls, style: style) do
      if text.nil?
        '<span class="fa fa-plus-square"></span>'.html_safe
      else
        text.html_safe
      end
    end
  end
end
