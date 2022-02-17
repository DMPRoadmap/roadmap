# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Locales', type: :feature, js: true do
  before(:each) do
    # Clear out the default defined in the locales support file
    Language.destroy_all
  end

  let!(:languages) do
    [
      Language.where(
        default_language: true,
        name: 'English',
        abbreviation: 'en-GB'
      ).first_or_create,

      Language.where(
        default_language: false,
        name: 'German',
        abbreviation: 'de'
      ).first_or_create,

      Language.where(
        default_language: false,
        name: 'Portugese',
        abbreviation: 'pt-BR'
      ).first_or_create

    ]
  end

  let!(:user) { create(:user, language: languages.first) }

  before do
    locales = %w[en-GB de pt-BR]
    I18n.available_locales = locales
    I18n.locale = locales.first
    sign_in(user)
    visit root_path
  end

  after do
    locales = AVAILABLE_TEST_LOCALES
    I18n.available_locales = locales
    I18n.default_locale = locales.first
  end

  context 'when new locale has no region' do
    scenario 'user changes their locale' do
      create_plan_text = I18n.with_locale(:de) do
        _('Create plan')
      end

      click_link 'Language'
      expect(current_path).to eql(plans_path)
      expect(page).not_to have_text(create_plan_text)

      click_link 'German'
      expect(current_path).to eql(plans_path)
      expect(page).to have_text(create_plan_text)
    end
  end

  context 'when new locale has region' do
    scenario 'user changes their locale' do
      create_plan_text = I18n.with_locale('pt-BR') do
        _('Create plan')
      end
      click_link 'Language'
      expect(current_path).to eql(plans_path)
      expect(page).not_to have_text(create_plan_text)

      click_link 'Portugese'
      expect(current_path).to eql(plans_path)
      expect(page).to have_text(create_plan_text)
    end
  end
end
