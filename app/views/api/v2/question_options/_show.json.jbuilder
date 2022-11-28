# frozen_string_literal: true

# locals: question_option

json.is_default question_option.is_default
json.number question_option.number
json.text question_option.text
json.created question_option.created_at.to_formatted_s(:iso8601)
json.modified question_option.updated_at.to_formatted_s(:iso8601)
json.question_id question_option.question_id
