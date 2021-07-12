# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sign in via email and password", type: :feature do

  include DmptoolHelper

  before(:each) do
    @shibbolized_org = create(:org, :shibbolized, managed: true)
    @entity_id = @shibbolized_org.identifier_for_scheme(scheme: "shibboleth")

    @non_shibbolized_org = create(:org, managed: true)
    @unmanaged_org = create(:org, managed: false)

    @unknown_registry_org = create(:registry_org)
    @known_registry_org = create(:registry_org, org: @non_shibbolized_org)
    @unmanaged_registry_org = create(:registry_org, org: @unmanaged_org)

    @pwd = SecureRandom.uuid
    @linked_user = create(:user, password: @pwd, password_confirmation: @pwd, org: @shibbolized_org)
    create(:identifier, identifier_scheme: @entity_id.identifier_scheme, identifiable: @linked_user)
    @linked_user.reload

    @unlinked_user = create(:user, password: @pwd, password_confirmation: @pwd, org: @shibbolized_org)

    # -------------------------------------------------------------
    # start DMPTool customization
    # Mock the blog feed on our homepage
    # -------------------------------------------------------------
    mock_blog
    # -------------------------------------------------------------
    # end DMPTool customization
    # -------------------------------------------------------------

    visit root_path
  end

  scenario "User must select an institution" do
    within "#new_org" do
      click_button "Go"
      expect(page).to have_text("Please select an institution!")

      select_an_org("#shib-ds-org-controls", Faker::Movies::LordOfTheRings.character)
      click_button "Go"
    end

    expect(current_path).to eql(root_path)
    expect(page).to have_text("Please choose an institution from the list.")
  end

  scenario "User cannot select an unmanaged Org" do
    # Try an Org that is not managed
    within "#new_org" do
      select_an_org("#shib-ds-org-controls", @unmanaged_org.name)
      click_button "Go"
    end

    expect(current_path).to eql(root_path)
    expect(page).to have_text("Please choose an institution from the list.")

    # Next try for a RegistryOrg that has no associated Org
    within "#new_org" do
      select_an_org("#shib-ds-org-controls", @unknown_registry_org.name)
      click_button "Go"
    end

    expect(current_path).to eql(root_path)
    expect(page).to have_text("Please choose an institution from the list.")

    # Next try for a RegistryOrg that has associated Org that is not managed
    within "#new_org" do
      select_an_org("#shib-ds-org-controls", @unmanaged_registry_org.name)
      click_button "Go"
    end

    expect(current_path).to eql(root_path)
    expect(page).to have_text("Please choose an institution from the list.")
  end

  scenario "User cannot enter a custom Org name" do
    within "#new_org" do
      click_button "Go"
      expect(page).not_to have_text("I cannot find my institution in the list")
    end
  end

  context "config has shibboleth.use_filtered_discovery_service set to true" do
    scenario "Redirects to root if Shib did not send back data" do
      # Displays an error
    end

    scenario "The user has previously signed in via Shib SSO and is already linked" do
      # auto logs in if the entityID from shib matches the identifier
    end

    scenario "The user has never signed in via Shib SSO and the email matches" do
      # auto logs in if the email matches what Shib sent us
    end

    scenario "The user has an account but it is unlinked and the email from Shib has no match" do
      # redirected to org_branding page with Org name/logo
      # No org autocomplete should be visible
      # user can create account
    end

    scenario "The user has an account but the Org has no Shib entityID" do
      # redirects to the org_branding page with Org name / logo
      # No org autocomplete should be visible
      # user can sign in
    end

    scenario "The user does not have an account and the Org has no Shib entityID" do
      # redirects to the org_branding page with Org name / logo
      # No org autocomplete should be visible
      # user can create account
    end
  end

  context "config has shibboleth.use_filtered_discovery_service set to false" do
    scenario "User is redirected to the federated discovery service" do
      # redirects to the federated discovery service
    end

    scenario "User is redirected to root if there is a Shib error" do
      # redirects to root if no Shib data was returned
    end

    scenario "User is logged in if they are already linked" do
      # auto log in
    end

    scenario "User is logged in if they are not linked but the Shib email matches" do
      # auto logs them in
    end

    scenario "The user has an account but email from Shib did not match" do
      # redirects to the org_branding page with Org name / logo
      # No org autocomplete should be visible
      # user can sign in
    end

    scenario "The user does not have an account" do
      # redirects to the org_branding page with Org name / logo
      # No org autocomplete should be visible
      # user can create account
    end
  end

end
