require 'rails_helper'

RSpec.feature "Locales", type: :feature, js: true do

  let!(:languages) {
    [
      Language.where(
        default_language: true,
        name: "English",
        abbreviation: "en-GB"
      ).first_or_create,

      Language.where(
        default_language: false,
        name: "German",
        abbreviation: "de"
      ).first_or_create
    ]
  }

  let!(:user) { create(:user, language: languages.first) }

  before do
    locale_set = LocaleSet.new(languages.map(&:abbreviation))
    I18n.available_locales        = locale_set.for(:i18n)
    FastGettext.default_available_locales = locale_set.for(:fast_gettext)
    I18n.locale                   = locale_set.for(:i18n).first
    FastGettext.locale            = locale_set.for(:fast_gettext).first
    sign_in(user)
  end

  after do
    I18n.available_locales        = AVAILABLE_TEST_LOCALES.for(:i18n)
    FastGettext.default_available_locales = AVAILABLE_TEST_LOCALES.for(:fast_gettext)
    I18n.default_locale           = AVAILABLE_TEST_LOCALES.for(:i18n).first
    FastGettext.default_locale    = AVAILABLE_TEST_LOCALES.for(:fast_gettext).first
  end

  scenario "user changes their locale" do
    click_link "Language"
    expect(current_path).to eql(plans_path)
    expect(page).not_to have_text("Erstelle Plan")

    click_link languages.last.name
    expect(current_path).to eql(plans_path)
    expect(page).to have_text("Erstelle Plan")
  end

end
