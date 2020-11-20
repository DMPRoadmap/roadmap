# frozen_string_literal: true

require "shoulda/matchers"

AVAILABLE_TEST_LOCALES = %w[en-GB en fr de].freeze

RSpec.configure do |config|

  config.before(:suite) do
    # This is required for the Faker gem. See this issue here:
    # https://github.com/stympy/faker/issues/266
    I18n.available_locales = AVAILABLE_TEST_LOCALES
    default_locale = AVAILABLE_TEST_LOCALES.first
    I18n.default_locale = default_locale

    unless Language.default.present?
      Language.create(name: default_locale, abbreviation: default_locale,
                      default_language: true)
    end
  end

  config.before(:each, type: :feature) do
    default_locale = AVAILABLE_TEST_LOCALES.first
    I18n.config.locale = default_locale
  end

end
