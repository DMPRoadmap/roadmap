module DMPonline4
  class Application < Rails::Application

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # Set the list of locales that we will support here (ie those for which we have translations for the DMPOnline application)
    # tell the I18n library where to find your translations
    config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # set default locale
    # in config/initializers/locale.rb

    # set default locale to something other than :en
    config.i18n.default_locale = Language.where(default_language: true).first.abbreviation

    # set fallback locale
    config.i18n.fallbacks = true
  end
end
