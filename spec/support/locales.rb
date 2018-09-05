# frozen_string_literal: true

require 'shoulda/matchers'

AVAILABLE_TEST_LOCALES = %w[ en en_GB fr de ]

RSpec.configure do |config|
  config.before(:each, type: :feature) do
    I18n.config.enforce_available_locales = false
    I18n.config.available_locales = AVAILABLE_TEST_LOCALES
  end
end
