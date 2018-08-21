require 'rails_helper'

RSpec.feature "Locales", type: :feature, js: true do

  let!(:languages) {
    [
      Language.where(default_language: true, name: "English", abbreviation: "en_GB").first_or_create,
      Language.where(default_language: false, name: "German", abbreviation: "de").first_or_create
    ]
  }

  let!(:user) { create(:user, language: languages.first) }

  before do
    FastGettext.default_available_locales << languages.last.abbreviation
    sign_in(user)
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
