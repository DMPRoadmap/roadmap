# frozen_string_literal: true

class UrlValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    reg = %r{https?://[-a-zA-Z0-9@:%_+.~#?&/=]{2,256}\.[a-z]{2,4}\b(/[-a-zA-Z0-9@:%_+.~#?&/=]*)?}
    return unless value =~ reg

    record.errors[attribute] << (options[:message] || "is not a valid URL")
  end

end
