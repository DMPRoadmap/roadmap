# frozen_string_literal: true

# Here we define the translation domains for the Roadmap application, `app` will
# contain translations from the open-source repository and ignore the contents
# of the `app/views/branded` directory.  The `client` domain will
#
# When running the application, the `app` domain should be specified in your environment.
# the `app` domain will be searched first, falling back to `client`
#
# When generating the translations, the rake:tasks will need to be run with each
# domain specified in order to generate both sets of translation keys.
if !ENV['DOMAIN'] || ENV.fetch('DOMAIN', nil) == 'app'
  TranslationIO.configure do |config|
    config.api_key              = Rails.configuration.x.dmproadmap.translation_io_key_app
    config.source_locale        = 'en'
    config.target_locales       = %w[de en-GB en-US es fr-FR fi sv-FI pt-BR en-CA fr-CA tr-TR]
    config.text_domain          = 'app'
    config.bound_text_domains   = %w[app client]
    config.ignored_source_paths = Dir.glob('**/*').select { |f| File.directory? f }
                                     .collect { |name| "#{name}/" }
                                     .select do |path|
                                       path.include?('branded/') ||
                                         path.include?('dmptool/') ||
                                         path.include?('node_modules/')
                                     end
    config.locales_path         = Rails.root.join('config', 'locale')
  end
elsif ENV.fetch('DOMAIN', nil) == 'client'
  # Control ignored source paths
  # Note, all prefixes of the directory you want to translate must be defined here!
  #
  # To sync translations with the Translation IO server run:
  #  > rails translation:sync_and_purge DOMAIN=client
  TranslationIO.configure do |config|
    config.api_key              = Rails.configuration.x.dmproadmap.translation_io_key_client
    config.source_locale        = 'en'
    config.target_locales       = %w[en-US pt-BR]
    config.text_domain          = 'client'
    config.bound_text_domains = ['client']
    config.ignored_source_paths = Dir.glob('**/*').select { |f| File.directory? f }
                                     .collect { |name| "#{name}/" }
                                     .reject do |path|
                                       path == 'app/' || path == 'app/views/' ||
                                         path.include?('branded/') || path.include?('dmptool/')
                                     end
    config.disable_yaml         = true
    config.locales_path         = Rails.root.join('config', 'locale')
  end
end

# Setup languages
# rubocop:disable Style/RescueModifier
table = ActiveRecord::Base.connection.table_exists?('languages') rescue false
# rubocop:enable Style/RescueModifier
if table
  def default_locale
    Language.default.try(:abbreviation) || 'en-US'
  end

  def available_locales
    Language.sorted_by_abbreviation.pluck(:abbreviation).presence || [default_locale]
  end

  I18n.available_locales = Language.all.pluck(:abbreviation)

  I18n.default_locale = Language.default.try(:abbreviation) || 'en' # || "en-US"
else
  def default_locale
    Rails.application.config.i18n.available_locales.first || 'en-US'
  end

  def available_locales
    Rails.application.config.i18n.available_locales = %w[en-US pt-BR]
  end

  I18n.available_locales = ['en-US']

  I18n.default_locale = 'en-US'
end
