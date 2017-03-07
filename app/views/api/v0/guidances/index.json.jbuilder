# builds a json response to api querry for all guidances

json.prettify!

json.guidance @all_viewable_guidances do |guidance|
  json.id     guidance.id
  json.text   guidance.text
  json.updated_at   guidance.updated_at

  # each guidance may be associated with many guidance groups
  guidance_group = guidance.guidance_group
  unless guidance_group.nil?
    json.guidance_group do
      json.name       guidance_group.name
      json.id         guidance_group.id

      json.optional   guidance_group.optional_subset
      json.updated    guidance_group.updated_at
    end
  end

end
