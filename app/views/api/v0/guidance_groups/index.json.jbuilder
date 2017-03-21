# builds a json response to api query for a list of guidance groups
json.prettify!

json.guidance_groups @all_viewable_groups do |guidance_group|
  json.name       guidance_group.name
  json.id         guidance_group.id

  # for each template associated with the guidance group, list the template name
  @templates = guidance_group.dmptemplates
  # if the template is empty, instead use all avalable templates
  if @templates.empty?
    @templates = Dmptemplate.all
  end
  json.templates @templates do |template|
    json.title    template.title
    json.id       template.id
  end

  json.optional   guidance_group.optional_subset
  json.updated    guidance_group.updated_at
end
