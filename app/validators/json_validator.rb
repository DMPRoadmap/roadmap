# frozen_string_literal: true

# Validation for email format
class JsonValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << 'is not valid json' unless valid_json?(value)
  end

  private

  def valid_json?(value)
    !!JSON.parse(value)
  rescue StandardError
    false
  end
end
