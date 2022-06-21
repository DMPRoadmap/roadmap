# frozen_string_literal: true

# locals: phase

json.title phase.title
json.description phase.description
json.number phase.number
json.template_id phase.template_id
json.modifiable phase.modifiable
json.created phase.created_at.to_formatted_s(:iso8601)
json.modified phase.updated_at.to_formatted_s(:iso8601)

json.sections phase.sections do |section|
  json.partial! 'api/v2/sections/show', section: section
end
