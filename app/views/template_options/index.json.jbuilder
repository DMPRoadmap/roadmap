# frozen_string_literal: true

json.templates do
  json.array! @templates do |template|
    json.id template.id
    json.title template.title
  end
end
