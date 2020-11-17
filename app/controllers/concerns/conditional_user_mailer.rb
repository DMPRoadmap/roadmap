# frozen_string_literal: true

module ConditionalUserMailer

  # Executes a given block passed if the recipient user has the preference
  # email key enabled
  #
  # recipients - User or Enumerable object or any object that includes Enumerable class
  # key        - A key (dot notation) whose value is true/false and belongs to
  #              prefences.email (see dmproadmap.rb initializer)
  #
  # Returns Boolean
  def deliver_if(recipients: [], key:, &block)
    return false unless block_given?

    Array(recipients).each do |recipient|
      email_hash = recipient.get_preferences("email").with_indifferent_access
      # Violation of rubocop's DoubleNegation check
      # preference_value = !!email_hash.dig(*key.to_s.split("."))
      preference_value = email_hash.dig(*key.to_s.split("."))
      block.call(recipient) if preference_value
    end

    true
  end

end
