# frozen_string_literal: true

# locals: section

json.title section.title
json.description section.description
json.number section.number
json.phase_id section.phase_id
json.modifiable section.modifiable
json.created section.created_at.to_formatted_s(:iso8601)
json.modified section.updated_at.to_formatted_s(:iso8601)

json.questions section.questions do |question|
  json.partial! 'api/v2/questions/show', question: question
end
