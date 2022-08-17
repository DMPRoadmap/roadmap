### This seed file includes all data that is not exported directly from the old database

default_locale = LocaleService.to_i18n(locale: LocaleService.default_locale).to_s
default_language = Language.find_by(abbreviation: default_locale)

I18n.available_locales = LocaleService.available_locales.map do |locale|
  LocaleService.to_i18n(locale: locale)
end
I18n.available_locales << :en unless I18n.available_locales.include?(:en)
I18n.default_locale = default_locale

