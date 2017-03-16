# builds a json response to api query for a list of guidance groups
json.prettify!

json.guidance_group do
  json.name       @guidance_group.name
  json.id         @guidance_group.id

  json.guidances @guidance_group.guidances do |guidance|
    json.text guidance.text
    json.id   guidance.id
  end
  json.optional   @guidance_group.optional_subset
  json.updated    @guidance_group.updated_at
end
