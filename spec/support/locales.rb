# frozen_string_literal: true

require 'shoulda/matchers'

AVAILABLE_TEST_LOCALES = %w[en-GB en fr de].freeze

RSpec.configure do |config|

  config.before(:suite) do
    # This is required for the Faker gem. See this issue here:
    # https://github.com/stympy/faker/issues/266
    I18n.available_locales = AVAILABLE_TEST_LOCALES.map do |locale|
      LocaleService.to_i18n(locale: locale)
    end
    FastGettext.default_available_locales = AVAILABLE_TEST_LOCALES.map do |locale|
      LocaleService.to_gettext(locale: locale)
    end
    default_locale = AVAILABLE_TEST_LOCALES.first
    I18n.default_locale = LocaleService.to_i18n(locale: default_locale)
    FastGettext.default_locale = LocaleService.to_gettext(locale: default_locale)

    unless Language.default.present?
      Language.create(name: default_locale, abbreviation: default_locale,
                      default_language: true)
    end
  end

  config.before(:each, type: :feature) do
    I18n.config.enforce_available_locales = true
    default_locale = AVAILABLE_TEST_LOCALES.first
    I18n.config.locale = LocaleService.to_i18n(locale: default_locale)
    FastGettext.locale = LocaleService.to_gettext(locale: default_locale)
  end

end
