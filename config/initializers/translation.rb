# frozen_string_literal: true

# New with Rails 6+, we need to define the list of locales outside the context of
# the Database since thiss runs during startup. Trying to access the DB causes
# issues with autoloading; 'DEPRECATION WARNING: Initialization autoloaded the constants ... Language'
#
# Note that the entries here must have a corresponding directory in config/locale, a
# YAML file in config/locales and should also have an entry in the DB's languages table
SUPPORTED_LOCALES = %w[de en-CA en-GB en-US es fi fr-CA fr-FR pt-BR sv-FI tr-TR].freeze
# You can define a subset of the locales for your instance's version of Translation.io if applicable
CLIENT_LOCALES = %w[de en-CA en-GB en-US es fi fr-CA fr-FR pt-BR sv-FI tr-TR].freeze
DEFAULT_LOCALE = 'en-GB'
# Here we define the translation domains for the Roadmap application, `app` will
# contain translations from the open-source repository and ignore the contents
# of the `app/views/branded` directory.  The `client` domain will
#
# When running the application, the `app` domain should be specified in your environment.
# the `app` domain will be searched first, falling back to `client`
#
# When generating the translations, the rake:tasks will need to be run with each
# domain specified in order to generate both sets of translation keys.
if !ENV['DOMAIN'] || ENV['DOMAIN'] == 'app'
  TranslationIO.configure do |config|
    config.api_key              = ENV.fetch('TRANSLATION_API_ROADMAP', nil)
    config.source_locale        = 'en'
    config.target_locales       = SUPPORTED_LOCALES
    config.text_domain          = 'app'
    config.bound_text_domains   = %w[app client]
    config.ignored_source_paths = ['app/views/branded/', 'node_modules/']
    config.locales_path         = Rails.root.join('config', 'locale')
  end
elsif ENV['DOMAIN'] == 'client'
  TranslationIO.configure do |config|
    config.api_key              = ENV.fetch('TRANSLATION_API_CLIENT', nil)
    config.source_locale        = 'en'
    config.target_locales       = CLIENT_LOCALES
    config.text_domain          = 'client'
    config.bound_text_domains = ['client']
    config.ignored_source_paths = ignore_paths
    config.disable_yaml         = true
    config.locales_path         = Rails.root.join('config', 'locale')
  end
end

# Control ignored source paths
# Note, all prefixes of the directory you want to translate must be defined here
def ignore_paths
  Dir.glob('**/*').select { |f| File.directory? f }
     .collect { |name| "#{name}/" }
  - ['app/',
     'node_modules/',
     'app/views/',
     'app/views/branded/',
     'app/views/branded/public_pages/',
     'app/views/branded/home/',
     'app/views/branded/contact_us/',
     'app/views/branded/contact_us/contacts/',
     'app/views/branded/shared/',
     'app/views/branded/layouts/',
     'app/views/branded/static_pages/']
end

# Setup languages
def default_locale
  DEFAULT_LOCALE
end

def available_locales
  SUPPORTED_LOCALES.sort { |a, b| a <=> b }
end

I18n.available_locales = SUPPORTED_LOCALES

I18n.default_locale = DEFAULT_LOCALE
