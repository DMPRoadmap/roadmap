# builds a json response to api querry for a specific guidance

json.prettify!

json.guidance do
  json.id     @guidance.id
  json.text   @guidance.text
  json.updated_at   @guidance.updated_at

  # each guidance may be associated with one guidance group
  guidance_group = @guidance.guidance_group

  unless guidance_group.nil?
    json.guidance_group do
      json.name       guidance_group.name
      json.id         guidance_group.id

      json.optional   guidance_group.optional_subset
      json.updated    guidance_group.updated_at
    end
  end
end