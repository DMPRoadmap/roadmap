# builds a json response to api querry for all guidances

json.prettify!

json.guidance @all_viewable_guidances do |guidance|
  json.id     guidance.id
  json.text   guidance.text
  json.updated_at   guidance.updated_at

  # each guidance may be associated with many guidance groups
  @guidance_groups = guidance.guidance_groups
  json.guidance_groups @guidance_groups do |guidance_group|
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
    end
    json.optional   guidance_group.optional_subset
    json.updated    guidance_group.updated_at
  end

end
