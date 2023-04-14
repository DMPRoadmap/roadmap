# frozen_string_literal: true

require 'shoulda/matchers'

AVAILABLE_TEST_LOCALES = %w[en-US en].freeze

RSpec.configure do |config|
  config.before(:suite) do
    # This is required for the Faker gem. See this issue here:
    # https://github.com/stympy/faker/issues/266
    I18n.available_locales = AVAILABLE_TEST_LOCALES
    default_locale = AVAILABLE_TEST_LOCALES.first
    I18n.default_locale = default_locale

    if Language.default.blank?
      Language.create(name: default_locale, abbreviation: default_locale,
                      default_language: true)
    end
  end

  config.before(:each, type: :feature) do
    default_locale = AVAILABLE_TEST_LOCALES.first
    I18n.config.locale = default_locale
  end
end
