# Provides a helper utility for loading branding configs.
module Branding

  module_function

  # Loads branding config from YAML file.
  #
  # keys - A list of the keys to return configs for.
  #
  # Examples:
  #
  #   # Return a value
  #   Branding.fetch(:settings, :should_work) # => true
  #   Branding.fetch(:settings, :email) # => 'user@example.com'
  #   Branding.fetch(:settings, :missing) # => nil
  #
  # Returns Object
  def fetch(*keys)
    keys = keys.map(&:to_sym)
    Rails.configuration.branding.dig(*keys)
  end
end
