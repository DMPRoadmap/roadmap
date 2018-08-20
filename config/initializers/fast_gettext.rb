# When Travis runs this, the DB isn't always built yet.
if Language.table_exists?
  def default_locale
    Language.default.try(:abbreviation) || 'en_GB'
  end

  def available_locales
    Language.sorted_by_abbreviation.pluck(:abbreviation).presence || [default_locale]
  end
else
  def default_locale
    Rails.application.config.i18n.available_locales.first
  end

  def available_locales
    Rails.application.config.i18n.available_locales
  end
end

FastGettext.add_text_domain('app', {
  path: 'config/locale',
  type: :po,
  ignore_fuzzy: true,
  report_warning: false,
})

FastGettext.default_text_domain       = 'app'
FastGettext.default_locale            = default_locale
FastGettext.default_available_locales = available_locales
