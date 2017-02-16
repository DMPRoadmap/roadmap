# builds a json response to api query for a list of all dmptemplates
json.prettify!

json.templates @org_templates.each do |org, templates|
    json.organisation_name    org.name
    json.organisation_id      org.id
    json.organisation_templates templates.each do |_, template|
      json.title        template.title
      json.id           template.id
      json.description  template.description
    end
end