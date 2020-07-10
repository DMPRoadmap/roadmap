# frozen_string_literal: true

# Since this initializer accesses ActiveRecord we need to wait until it has
# finished initializing
Rails.configuration.after_initialize do

  FastGettext.add_text_domain "app", path: "config/locale", type: :po,
                                     ignore_fuzzy: true, report_warning: true
  FastGettext.default_text_domain = "app"

  available = LocaleService.available_locales
  default = LocaleService.default_locale

  # FastGettext config
  FastGettext.default_available_locales = available.map do |locale|
    LocaleService.to_gettext(locale: locale)
  end
  FastGettext.default_locale = LocaleService.to_gettext(locale: default).to_s
  # rubocop:enable Layout/LineLength

  # I18n config
  I18n.available_locales += available.map do |locale|
    LocaleService.to_i18n(locale: locale)
  end
  I18n.default_locale = LocaleService.to_i18n(locale: default).to_s

# When running `db:setup` or `db:create` this error is thrown because the DB is
# not available yet, so write a warning to the log and get on with life!
rescue ActiveRecord::NoDatabaseError => e
  p "here #{e.message}"
  Rails.logger.warn "No database available, skipping FastGettext locale initialization"
  true
end
