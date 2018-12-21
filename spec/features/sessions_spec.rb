require 'rails_helper'

RSpec.feature "Sessions", type: :feature do

  # -------------------------------------------------------------
  # start DMPTool customization
  # Initialize the is_other org
  # -------------------------------------------------------------
  include DmptoolHelper
  # -------------------------------------------------------------
  # end DMPTool customization
  # -------------------------------------------------------------

  let(:user) { create(:user) }

  scenario "User signs in successfully with email and password", :js do
    # Setup
    visit root_path

    # -------------------------------------------------------------
    # start DMPTool customization
    # Access the signin form
    # -------------------------------------------------------------
    access_sign_in_modal
    # -------------------------------------------------------------
    # end DMPTool customization
    # -------------------------------------------------------------

    # Action
    fill_in :signin_user_email, with: user.email
    fill_in :signin_user_password, with: user.password
    click_button "Sign in"

    # Expectation
    expect(current_path).to eql(plans_path)
    expect(page).to have_text(user.firstname)
    expect(page).to have_text(user.surname)
  end

  scenario "User fails sign in with email and password", :js do
    # Setup
    visit root_path

    # -------------------------------------------------------------
    # start DMPTool customization
    # Access the signin form
    # -------------------------------------------------------------
    access_sign_in_modal
    # -------------------------------------------------------------
    # end DMPTool customization
    # -------------------------------------------------------------

    # Action
    fill_in :signin_user_email, with: user.email
    fill_in :signin_user_password, with: "rong-password"
    click_button "Sign in"

    # Expectation
    expect(current_path).to eql(root_path)
    expect(page).not_to have_text(user.firstname)
    expect(page).not_to have_text(user.surname)
    expect(page).to have_text("Error")
  end

  # -------------------------------------------------------------
  # start DMPTool customization
  # Shibboleth sign in
  # -------------------------------------------------------------
  scenario "User signs in successfully via Shibboleth", :js do
    generate_shibbolized_orgs(12)
    org = Org.participating.first

    # Setup
    visit root_path
    access_shib_ds_modal
    find("#shib-ds_org_name").set(org.name)
    ## Click from the dropdown autocomplete
    find("#suggestion-1-0").click
    #click_button "Go"
    click_link "See the full list of participating institutions"
    click_link "#{org.name}"

    # TODO: Finish these tests!
    #       Clicking the final link goes into orgs/shibboleth_ds_passthru
    #       which redirects to: /Shibboleth.sso/Login?target=https://127.0.0.1:63956/users/auth/shibboleth/callback&entityID=animi
    # That call to Shibboleth.sso/Login is part of the Shib SP which we need to mock
    # to send traffic back to the users/auth/shibboleth route so that it falls into the
    # omniauth mock

    expect(current_path).to eql(edit_user_registration_path)
    #shib_id = UserIdentifier.where(user_id: user.id, identifier_scheme_id: scheme.id)
    #expect(shib_id).to eql("123ABC")
  end

  scenario "User fails sign in via Shibboleth", :js do

  end
  # -------------------------------------------------------------
    # end DMPTool customization
    # -------------------------------------------------------------

end
