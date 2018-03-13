module TemplateHelper
  def links_to_a_elements(links, separator = ', ')
    a = links.map do |l|
      "<a href=\"#{l['link']}\">#{l['text']}</a>"
    end
    a.join(separator)
  end
end