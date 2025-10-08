# frozen_string_literal: true

# Determines whether or not the user has enabled/disabled the email notification
# before sending it out
module ConditionalUserMailer
  # Executes a given block passed if the recipient user has the preference
  # email key enabled
  #
  # recipients - User or Enumerable object or any object that includes Enumerable class
  # key        - A key (dot notation) whose value is true/false and belongs to
  #              preferences.email (see dmproadmap.rb initializer)
  #
  # Returns Boolean
  def deliver_if(key:, recipients: [], &block)
    return false unless block

    Array(recipients).each do |recipient|
      email_hash = recipient.get_preferences('email').with_indifferent_access
      # Violation of rubocop's DoubleNegation check
      # preference_value = !!email_hash.dig(*key.to_s.split("."))
      preference_value = email_hash.dig(*key.to_s.split('.'))
      yield(recipient) if preference_value
    end

    true
  end
end
