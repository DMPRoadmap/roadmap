if !ENV['DOMAIN'] || ENV['DOMAIN'] == 'app'
  TranslationIO.configure do |config|
    config.api_key              = ENV['TRANSLATION_API_ROADMAP']
    config.source_locale        = 'en'
    config.target_locales       = ['de', 'en-GB', 'en-US', 'es', 'fr-FR', 'fi', 'sv-FI', 'pt-BR']
    config.text_domain          = 'app'
    config.bound_text_domains   = ['app', 'client']
    config.ignored_source_paths = ['app/views/branded/']
  end
elsif ENV['DOMAIN'] == 'client'
  TranslationIO.configure do |config|
    config.api_key              = ENV['TRANSLATION_API_TUULI']
    config.source_locale        = 'en'
    config.target_locales       = ['fi', 'sv-FI']
    config.text_domain          = 'client'
    config.bound_text_domains   =['client']
    config.ignored_source_paths = Dir.glob('**/*').select { |f| File.directory? f }.collect { |name| "#{name}/" } - ['app/', 'app/views/', 'app/views/branded/', "app/views/branded/public_pages/", "app/views/branded/home/", "app/views/branded/contact_us/", "app/views/branded/contact_us/contacts/", "app/views/branded/shared/", "app/views/branded/layouts/", "app/views/branded/static_pages/"]
    config.disable_yaml         = true
  end
end

# configure shared options
TranslationIO.configure do |config|
  config.locales_path = Rails.root.join('config','locale')
end

# Setup languages
if Language.table_exists?
  def default_locale
    Language.default.try(:abbreviation) || "en"
  end

  def available_locales
    LocaleSet.new(
      Language.sorted_by_abbreviation.pluck(:abbreviation).presence || [default_locale]
    )
  end
else
  def default_locale
    Rails.application.config.i18n.available_locales.first || "en"
  end

  def available_locales
    Rails.application.config.i18n.available_locales = LocaleSet.new(["en-GB", "en"])
  end
end


I18n.available_locales = Language.all.pluck(:abbreviation)

I18n.default_locale        = Language.default.try(:abbreviation) || "en-GB"
