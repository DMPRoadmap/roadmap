module DMPonline4
  class Application < Rails::Application

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # Set the list of locales that we will support here (ie those for which we have translations for the DMPOnline application)
    # tell the I18n library where to find your translations
    config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # set default locale
    # in config/initializers/locale.rb

    # set default locale to something other than :en
    # initializers are run before migrations, languages table might not be present
    if ActiveRecord::Base.connection.tables.include?('languages') &&
          ActiveRecord::Base.connection.column_exists?(:languages, :default_language)
          
      # If a default language is not defined in the DB use en-UK
      if Language.where(default_language: true).empty?
        config.i18n.default_locale = 'en-UK'
      else
        config.i18n.default_locale = Language.where(default_language: true).first.abbreviation
      end
      
    else
      config.i18n.default_locale = 'en-UK' # if this is not set then admin area is not working, which is required to change the default_language
    end

    # set fallback locale
    config.i18n.fallbacks = true
  end
end