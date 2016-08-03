json.prettify!

json.plans @org_projects.each do |project|
  json.id             project.id
  json.grant_number   project.grant_number
  json.org_id         project.organisation_id
  json.template do
    json.title        project.dmptemplate.title
    json.id           project.dmptemplate.id
  end
  json.project do
    json.title        project.title
  end
  json.funder do
    json.name         project.funder_name
  end
  json.principal_investigator do
    json.name         project.principal_investigator
  end
  json.data_contact do
    json.info         project.data_contact
  end
  json.description    project.description

end