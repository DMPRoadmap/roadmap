# frozen_string_literal: true

json.templates do
  json.array! @templates do |template|
    json.id template.id
    json.title template.title
    json.default template.is_default?
  end
end
