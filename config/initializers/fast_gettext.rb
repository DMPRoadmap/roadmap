# frozen_string_literal: true

# When Travis runs this, the DB isn't always built yet.
if Language.table_exists?
  def default_locale
    Language.default.try(:abbreviation) || "en-GB"
  end

  def available_locales
    LocaleSet.new(
      Language.sorted_by_abbreviation.pluck(:abbreviation).presence || [default_locale]
    )
  end
else
  def default_locale
    Rails.application.config.i18n.available_locales.first || "en-GB"
  end

  def available_locales
    Rails.application.config.i18n.available_locales = LocaleSet.new(["en-GB", "en"])
  end
end

FastGettext.add_text_domain("app",
  path: "config/locale",
  type: :po,
  ignore_fuzzy: true,
  report_warning: false,
)

I18n.available_locales += available_locales.for(:i18n)
FastGettext.default_available_locales = available_locales.for(:fast_gettext)

FastGettext.default_text_domain       = "app"

I18n.default_locale        = LocaleFormatter.new(default_locale,
                                                 format: :i18n).to_s
FastGettext.default_locale = LocaleFormatter.new(default_locale,
                                                 format: :fast_gettext).to_s
