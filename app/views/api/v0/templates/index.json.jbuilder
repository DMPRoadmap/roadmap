# builds a json response to api query for a list of all templates
json.prettify!

json.templates @org_templates.each do |org, templates|
  json.organisation_name    org.name
  json.organisation_id      org.id
  json.is_funder            org.funder?
  json.organisation_templates templates[:own].each do |_, template|
    json.title              template.title
    json.id                 template.family_id
    json.description        template.description
  end
  json.customized_templates  templates[:cust].each do |_,template|
    json.title              template.title
    json.id                 template.family_id
    json.customization_of   template.customization_of
    json.description        template.description
  end
end