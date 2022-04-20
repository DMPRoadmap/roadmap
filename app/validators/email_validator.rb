# frozen_string_literal: true

<<<<<<< HEAD
=======
# Validation for email format
>>>>>>> upstream/master
class EmailValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    return if value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

<<<<<<< HEAD
    record.errors[attribute] << (options[:message] || "is not a valid email address")
  end

=======
    record.errors[attribute] << (options[:message] || 'is not a valid email address')
  end
>>>>>>> upstream/master
end
