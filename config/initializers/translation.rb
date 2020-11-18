TranslationIO.configure do |config|
  config.api_key        = 'c3a3ba83cc4640409cc0ae52a459b80a'
  config.source_locale  = 'en'
  config.target_locales = ['en-CA', 'en-GB', 'fr-CA']
  
  # Uncomment this if you don't want to use gettext
  # config.disable_gettext = true

  # Uncomment this if you already use gettext or fast_gettext
  config.locales_path = File.join('config', 'locale')

  # Find other useful usage information here:
  # https://github.com/translation/rails#readme
end