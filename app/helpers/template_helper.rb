module TemplateHelper
  def links_to_a_elements(links)
    a = links.map do |l|
      "<a href=\"#{l['link']}\">#{l['text']}</a>"
    end
    a.join(", ")
  end
end