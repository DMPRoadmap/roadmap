json.prettify!
templates = {}
@org_projects.each do |plan|
  # if hash exists
  if templates[plan.template.title].blank?
    templates[plan.template.title] = {}
      templates[plan.template.title][:title] = plan.template.title
      templates[plan.template.title][:id] = plan.template.id
      templates[plan.template.title][:uses] = 1
  else
    templates[plan.template.title][:uses] += 1
  end
end

json.templates templates.each do |template, info|
  json.template_name    info[:title]
  json.template_id      info[:id]
  json.template_uses    info[:uses]
end

