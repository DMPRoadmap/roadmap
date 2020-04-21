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
      ).first_or_create,

      Language.where(
        default_language: false,
        name: "Portugese",
        abbreviation: "pt-BR"
      ).first_or_create

    ]
  }

  let!(:user) { create(:user, language: languages.first) }

  before do
    locales = %w[en-GB de pt-BR]
    I18n.available_locales = locals.map { |l| LocalService.to_i18n(string: l) }
    FastGettext.default_available_locales = locals.map do |l|
      LocalService.to_gettext(string: l)
    end
    I18n.locale                   = LocalService.to_i18n(locale: locales.first)
    FastGettext.locale            = LocalService.to_gettext(locale: locales.first)
    sign_in(user)
  end

  after do
    #I18n.available_locales        = AVAILABLE_TEST_LOCALES.for(:i18n)
    #FastGettext.default_available_locales = AVAILABLE_TEST_LOCALES.for(:fast_gettext)
    #I18n.default_locale           = AVAILABLE_TEST_LOCALES.for(:i18n).first
    #FastGettext.default_locale    = AVAILABLE_TEST_LOCALES.for(:fast_gettext).first
  end

  context "when new locale has no region" do

    scenario "user changes their locale" do
      create_plan_text = "Erstelle Plan"
      click_link "Language"
      expect(current_path).to eql(plans_path)
      expect(page).not_to have_text(create_plan_text)

      click_link "German"
      expect(current_path).to eql(plans_path)
      expect(page).to have_text(create_plan_text)
    end

  end

  context "when new locale has region" do

    scenario "user changes their locale" do
      create_plan_text = "Criar plano"
      click_link "Language"
      expect(current_path).to eql(plans_path)
      expect(page).not_to have_text(create_plan_text)

      click_link "Portugese"
      expect(current_path).to eql(plans_path)
      expect(page).to have_text(create_plan_text)
    end

  end
end
