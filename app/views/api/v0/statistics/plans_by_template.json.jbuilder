json.prettify!
templates = {}
@org_projects.each do |project|
  # if hash exists
  if templates[project.dmptemplate.title].blank?
    templates[project.dmptemplate.title] = {}
      templates[project.dmptemplate.title][:title] = project.dmptemplate.title
      templates[project.dmptemplate.title][:id] = project.dmptemplate.id
      templates[project.dmptemplate.title][:uses] = 1
  else
    templates[project.dmptemplate.title][:uses] += 1
  end
end

json.templates templates.each do |template, info|
  json.template_name    info[:title]
  json.template_id      info[:id]
  json.template_uses    info[:uses]
end

