# builds a json response to api query for a list of guidance groups
json.prettify!

json.guidance_groups @all_viewable_groups do |guidance_group|
  json.name       guidance_group.name
  json.id         guidance_group.id

  json.optional   guidance_group.optional_subset
  json.updated    guidance_group.updated_at
end
