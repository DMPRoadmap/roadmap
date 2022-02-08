# frozen_string_literal: true

pp @templates.map { |t| "#{t.id} -- #{t.title}" }

json.templates do
  json.array! @templates do |template|
    json.id template.id
    json.title template.title
  end
end
