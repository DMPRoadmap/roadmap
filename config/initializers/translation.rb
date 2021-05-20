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
if !ENV["DOMAIN"] || ENV["DOMAIN"] == "app"
  TranslationIO.configure do |config|
    config.api_key              = Rails.configuration.x.dmproadmap.translation_io_key
    config.source_locale        = "en"
    config.target_locales       = %w[de en-GB en-US es fr-FR fi sv-FI pt-BR en-CA fr-CA]
    config.text_domain          = "app"
    config.bound_text_domains   = %w[app client]
    config.ignored_source_paths = ["app/views/branded/"]
    config.locales_path         = Rails.root.join("config", "locale")
  end
elsif ENV["DOMAIN"] == "client"
  # Control ignored source paths
  # Note, all prefixes of the directory you want to translate must be defined here!
  #
  # To sync translations with the Translation IO server run:
  #  > rails translations:sync_and_purge DOMAIN=client
  # rubocop:disable Metrics/BlockLength
  TranslationIO.configure do |config|
    config.api_key              = Rails.application.dmproadmap.translation_io[:key]
    config.source_locale        = "en"
    config.target_locales       = %w[en-US pt-BR]
    config.text_domain          = "client"
    config.bound_text_domains = ["client"]
    config.ignored_source_paths = Dir.glob("**/*").select { |f| File.directory? f }
                                     .collect { |name| "#{name}/" } - [
                                       "app/",
                                       "app/views/",
                                       "app/views/branded/",
                                       "app/views/branded/contact_us/",
                                       "app/views/branded/contact_us/contacts/",
                                       "app/views/devise/",
                                       "app/views/devise/registrations/",
                                       "app/views/branded/home/",
                                       "app/views/branded/layouts/",
                                       "app/views/branded/layouts/mobile/",
                                       "app/views/branded/paginable/",
                                       "app/views/branded/paginable/orgs/",
                                       "app/views/branded/paginable/templates/",
                                       "app/views/branded/public_pages/",
                                       "app/views/branded/shared/",
                                       "app/views/branded/static_pages/",
                                       "app/controllers/",
                                       "app/controllers/dmptool/",
                                       "app/controllers/paginable/",
                                       "app/controllers/users/",
                                       "app/mailers/",
                                       "app/mailers/dmptool/",
                                       "app/presenters/",
                                       "app/presenters/dmptool/"
                                     ]
    config.disable_yaml         = true
    config.locales_path         = Rails.root.join("config", "locale")
  end
  # rubocop:enable Metrics/BlockLength
end

# Setup languages
# rubocop:disable Style/RescueModifier
table = ActiveRecord::Base.connection.table_exists?("languages") rescue false
# rubocop:enable Style/RescueModifier
if table
  def default_locale
    Language.default.try(:abbreviation) || "en-GB"
  end

  def available_locales
    Language.sorted_by_abbreviation.pluck(:abbreviation).presence || [default_locale]
  end

  I18n.available_locales = Language.all.pluck(:abbreviation)

  I18n.default_locale = Language.default.try(:abbreviation) || "en-GB"
else
  def default_locale
    Rails.application.config.i18n.available_locales.first || "en-GB"
  end

  def available_locales
    Rails.application.config.i18n.available_locales = %w[en-GB en-US]
  end

  I18n.available_locales = ["en-GB"]

  I18n.default_locale = "en-GB"
end
