# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sign up via email and password", type: :feature do

  include DmptoolHelper

  # TODO: implement this after we move to baseline homepage

  before(:each) do
    @existing = create(:user)
    @orgs = [create(:org), create(:org)]

    @first = Faker::Movies::StarWars.character.split(" ").first
    @last = Faker::Movies::StarWars.character.split(" ").last
    @email = Faker::Internet.unique.email
    @pwd = SecureRandom.uuid

    Rails.configuration.x.recaptcha.enabled = false

    # -------------------------------------------------------------
    # start DMPTool customization
    # Mock the blog feed on our homepage
    # -------------------------------------------------------------
    mock_blog
    # -------------------------------------------------------------
    # end DMPTool customization
    # -------------------------------------------------------------

    visit root_path

    # -------------------------------------------------------------
    # start DMPTool customization
    # Access the sign in form
    # -------------------------------------------------------------
    # Action
    #click_link "Create account"
#    access_create_account_modal
    # -------------------------------------------------------------
    # end DMPTool customization
    # -------------------------------------------------------------
  end

# We cannot do this until we move our homepage to baseline. too many damn create acount forms out there
=begin
  scenario "User signs up with an email attached to an existing user" do
    within("#create_account_form") do
      fill_in "First Name", with: @first
      fill_in "Last Name", with: @last
      fill_in "Email", with: @existing.email
      select_an_org("#new_user_org_name", @orgs.sample)
      fill_in "Password", with: @pwd
      check "I accept the terms and conditions"
      click_button "Create account"
    end

    expect(current_path).to eql(root_path)
    expect(page).to have_text("Error: Invalid Email or password.")
  end

  scenario "User signs up without specifying an email" do
    within("#create_account_form") do
      fill_in "First Name", with: @first
      fill_in "Last Name", with: @last
      fill_in "Email", with: nil
      select_an_org("#new_user_org_name", @orgs.sample)
      fill_in "Password", with: @pwd
      check "I accept the terms and conditions"
      click_button "Create account"
    end

    expect(current_path).to eql(root_path)
    expect(page).to have_text("Error: Invalid Email or password.")
  end

  scenario "User signs up without specifying an Org" do
    within("#create_account_form") do
      fill_in "First Name", with: @first
      fill_in "Last Name", with: @last
      fill_in "Email", with: @email
      select_an_org("#new_user_org_name", nil)
      fill_in "Password", with: @pwd
      check "I accept the terms and conditions"
      click_button "Create account"
    end

    expect(current_path).to eql(root_path)
    expect(page).to have_text("Error: Invalid Email or password.")
  end

  scenario "User signs up without specifying a password" do
    within("#create_account_form") do
      fill_in "First Name", with: @first
      fill_in "Last Name", with: @last
      fill_in "Email", with: @email
      select_an_org("#new_user_org_name", @orgs.sample)
      fill_in "Password", with: nil
      check "I accept the terms and conditions"
      click_button "Create account"
    end

    expect(current_path).to eql(root_path)
    expect(page).to have_text("Error: Invalid Email or password.")
  end

  scenario "User signs up with their email and password" do
    within("#create_account_form") do
      fill_in "First Name", with: @first
      fill_in "Last Name", with: @last
      fill_in "Email", with: @email
      select_an_org("#new_user_org_name", @orgs.sample)
      fill_in "Password", with: @pwd
      check "I accept the terms and conditions"
      click_button "Create account"
    end

    expect(current_path).to eql(plans_path)
    expect(page).to have_text("My Dashboard")
  end
=end

end