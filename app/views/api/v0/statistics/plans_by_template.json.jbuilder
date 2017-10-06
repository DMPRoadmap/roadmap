json.prettify!

json.templates @templates.each do |template, info|
  json.template_name    info[:title]
  json.template_id      info[:id]
  json.template_uses    info[:uses]
end