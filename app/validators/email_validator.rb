# frozen_string_literal: true

# Validation for email format
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

    record.errors.add(attribute, options.fetch(:message, 'is not a valid email address'))
  end
end
