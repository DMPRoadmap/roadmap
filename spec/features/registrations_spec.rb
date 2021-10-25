# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations", type: :feature do

  let!(:org) { create(:org) }
  let!(:language) { Language.default || create(:language, default_language: true) }

  let(:user_attributes) { attributes_for(:user) }

  scenario "User creates a new acccount", :js do
    # Setup
    visit root_path

    # Action
    click_link "Create account"
    within("#create-account-form") do
      fill_in "First Name", with: user_attributes[:firstname]
      fill_in "Last Name", with: user_attributes[:surname]
      fill_in "Email", with: user_attributes[:email]
      select_an_org("#new_user_org_name", org)
      fill_in "Password", with: user_attributes[:password]
      check "Show password"
      check "I accept the terms and conditions"
    end
    click_button "Create account"

    # Expectations
    expect(current_path).to eql(plans_path)
    expect(page).to have_text(user_attributes[:firstname])
    expect(page).to have_text(user_attributes[:surname])
  end

  scenario "User attempts to create a new acccount with invalid atts", :js do
    # Setup
    visit root_path

    # Action
    click_link "Create account"
    within("#create-account-form") do
      fill_in "First Name", with: user_attributes[:firstname]
      fill_in "Last Name", with: user_attributes[:surname]
      fill_in "Email", with: "invalid-email"
      select_an_org("#new_user_org_name", org)
      fill_in "Password", with: user_attributes[:password]
      check "Show password"
      check "I accept the terms and conditions"
    end
    click_button "Create account"

    # Expectations
    expect(current_path).to eql(root_path)
    expect(User.count).to be_zero
  end

end
