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
    config.api_key              = ENV["TRANSLATION_API_ROADMAP"]
    config.source_locale        = "en"
    config.target_locales       = %w[en-GB fr-FR]
    config.text_domain          = "app"
    config.bound_text_domains   = %w[app client]
    config.ignored_source_paths = Dir.glob("**/*").select { |f| File.directory? f }
                                     .collect { |name| "#{name}/" }
                                     .select { |path| path.include?("branded/") || path.include?("dmpopidor/") }
    config.locales_path         = Rails.root.join("config", "locale")
  end
elsif ENV["DOMAIN"] == "client"
  TranslationIO.configure do |config|
    config.api_key              = "026b1897373e47a68c06323f5b6888bd"
    config.source_locale        = "en"
    config.target_locales       = %w[en-GB fr-FR]
    config.text_domain          = "client"
    config.bound_text_domains   = ["client"]
    config.ignored_source_paths = Dir.glob("**/*").select { |f| File.directory? f }
                                     .collect { |name| "#{name}/" }
                                     .reject { |path|
                                       path == "app/" || path == "app/views/" ||
                                         path.include?("branded/") || path.include?("dmpopidor/") ||
                                         path.include?("madmp_") || path.include?("research_output")||
                                         path.include?("dynamic_form_helper")
                                     }
    config.disable_yaml         = true
    config.locales_path         = Rails.root.join("config", "locale")
  end
end

# Setup languages
# rubocop:disable Style/RescueModifier
table = ActiveRecord::Base.connection.table_exists?("languages") rescue false
# rubocop:enable Style/RescueModifier
if table
  def default_locale
    Language.default.try(:abbreviation) || "fr-FR"
  end

  def available_locales
    Language.sorted_by_abbreviation.pluck(:abbreviation).presence || [default_locale]
  end

  I18n.available_locales = Language.all.pluck(:abbreviation)

  I18n.default_locale = Language.default.try(:abbreviation) || "fr-FR"
else
  def default_locale
    Rails.application.config.i18n.available_locales.first || "fr-FR"
  end

  def available_locales
    Rails.application.config.i18n.available_locales = %w[en-GB fr-FR]
  end

  I18n.available_locales = %w[en-GB fr-FR]

  I18n.default_locale = "fr-FR"
end
