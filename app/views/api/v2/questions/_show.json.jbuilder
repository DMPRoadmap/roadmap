# frozen_string_literal: true

# locals: question

json.text question.text
json.default_value question.default_value
json.number question.number
json.section_id question.section_id
json.modifiable question.modifiable
json.created question.created_at.to_formatted_s(:iso8601)
json.modified question.updated_at.to_formatted_s(:iso8601)
json.question_format_id question.question_format_id
json.option_comment_display question.option_comment_display

json.annotations question.annotations do |annotation|
  json.partial! 'api/v2/annotations/show', annotation: annotation
end

json.question_options question.question_options do |question_option|
  json.partial! 'api/v2/question_options/show', question_option: question_option
end
