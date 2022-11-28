# frozen_string_literal: true

# locals: annotation

json.text annotation.text
json.type annotation.type
json.created annotation.created_at.to_formatted_s(:iso8601)
json.modified annotation.updated_at.to_formatted_s(:iso8601)
json.question_id annotation.question_id
json.org_id annotation.org_id
