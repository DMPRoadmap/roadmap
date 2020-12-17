require 'rails_helper'

RSpec.feature "Locales", type: :feature, js: true do

  let!(:languages) {
    [
      Language.where(
        default_language: true,
        name: "English (CA)",
        abbreviation: "en-CA"
      ).first_or_create,

      Language.where(
        default_language: false,
        name: "English (GB)",
        abbreviation: "en-GB"
      ).first_or_create,

      Language.where(
        default_language: false,
        name: "Français (CA)",
        abbreviation: "fr-CA"
      ).first_or_create

    ]
  }

  let!(:user) { create(:user, language: languages.first) }

  before do
    #locale_set = LocaleSet.new(%w[en-GB de pt-BR])
    locale_set = LocaleSet.new(%w[en-GB en-CA fr-CA])
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

  context "when new locale has no region" do
    
    scenario "user changes their locale" do
      skip 'We are now expecting locales to have region'
      create_plan_text = "Créer des plans"
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
      
      create_plan_text = "Créer des plans"
      click_link "Language"      
      expect(current_path).to eql(plans_path)
      expect(page).not_to have_text(create_plan_text)

      click_link "Français (CA)"
      expect(current_path).to eql(plans_path)
      expect(page).to have_text(create_plan_text)
    end

  end
end
