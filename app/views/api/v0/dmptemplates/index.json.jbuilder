# builds a json response to api query for a list of all dmptemplates
json.prettify!

json.templates Organisation.all.each do |org|
  unless org.published_templates.blank?
    json.organisation_name    org.name
    json.organisation_id      org.id
    json.organisation_templates org.published_templates.each do |template|
      json.title        template.title
      json.id           template.id
      json.description  template.description
    end
  end
end