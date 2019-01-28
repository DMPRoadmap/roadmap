require 'rails_helper'

RSpec.describe "Registrations", type: :feature do

  # -------------------------------------------------------------
  # start DMPTool customization
  # Initialize the is_other org
  # -------------------------------------------------------------
  include DmptoolHelper
  # -------------------------------------------------------------
  # end DMPTool customization
  # -------------------------------------------------------------

  let!(:org) { create(:org) }
  # -------------------------------------------------------------
  # start DMPTool customization
  #   We have been experiencing inconsistent results between the values
  #   returned by 'attributes_for' and what is actually submitted to the
  #   form in Chrome
  # -------------------------------------------------------------
  #let(:user_attributes) { attributes_for(:user) }
  let!(:user_attributes) { {
    firstname: "John",
    surname: "Doe",
    password: "testing123",
    email: "john.doe@testing-dmproadmap.org"
  } }
  # -------------------------------------------------------------
  # end DMPTool customization
  # -------------------------------------------------------------

  scenario "User creates a new acccount", :js do
    user_count = User.count

    # Setup
    visit root_path

    # -------------------------------------------------------------
    # start DMPTool customization
    # Access the create account form
    # -------------------------------------------------------------
    # Action
    #click_link "Create account"
    #within("#create-account-form") do
    access_create_account_modal
    within("#create_account_form") do
    # -------------------------------------------------------------
    # end DMPTool customization
    # -------------------------------------------------------------

      fill_in "First Name", with: user_attributes[:firstname]
      fill_in "Last Name", with: user_attributes[:surname]
      fill_in "Email", with: user_attributes[:email]

      # -------------------------------------------------------------
      # start DMPTool customization
      # We do not allow users to select an org
      # For some reason Chrome headless is triggering a:
      #     'Please include a '@' character' message sometimes
      # -------------------------------------------------------------
      #fill_in "Organisation", with: org.name
      ## Click from the dropdown autocomplete
      #find("#suggestion-1-0").click
      # -------------------------------------------------------------
      # end DMPTool customization
      # -------------------------------------------------------------

      fill_in "Password", with: user_attributes[:password]
      check "Show password"
      check "I accept the terms and conditions"
    end
    click_button "Create account"

# DMPTool issue
# For some reason this fails. It appears as though the button click is happening
# before the UI has a chance to fill in the email/password completely

    # Expectations
    expect(current_path).to eql(plans_path)
    expect(page).to have_text(user_attributes[:firstname])
    expect(page).to have_text(user_attributes[:surname])
  end

  scenario "User attempts to create a new acccount with invalid atts", :js do
    user_count = User.count

    # Setup
    visit root_path

    # -------------------------------------------------------------
    # start DMPTool customization
    # Access the create account form
    # -------------------------------------------------------------
    # Action
    #click_link "Create account"
    #within("#create-account-form") do
    access_create_account_modal
    within("#create_account_form") do
    # -------------------------------------------------------------
    # end DMPTool customization
    # -------------------------------------------------------------

      fill_in "First Name", with: user_attributes[:firstname]
      fill_in "Last Name", with: user_attributes[:surname]
      fill_in "Email", with: "invalid-email"

      # -------------------------------------------------------------
      # start DMPTool customization
      # We do not allow users to select an org
      # -------------------------------------------------------------
      #fill_in "Organisation", with: org.name
      ## Click from the dropdown autocomplete
      #find("#suggestion-1-0").click
      # -------------------------------------------------------------
      # end DMPTool customization
      # -------------------------------------------------------------

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