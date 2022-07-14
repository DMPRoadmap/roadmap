# frozen_string_literal: true

# Validation for URL format
class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    reg = %r{https?://[-a-zA-Z0-9@:%_+.~#?&/=]{2,256}\.[a-z]{2,4}\b(/[-a-zA-Z0-9@:%_+.~#?&/=]*)?}
    return unless value =~ reg

    record.errors.add(attribute, options.fetch(:message, 'is not a valid URL'))
  end
end
