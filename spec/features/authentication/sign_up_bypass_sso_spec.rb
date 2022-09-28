# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sign up and bypass SSO', type: :feature do
  include DmptoolHelper
  include AutocompleteHelper
  include IdentifierHelper

  before(:each) do
    mock_blog
    @email_domain = 'foo.edu'
    @org = create(:org, contact_email: "help-desk@#{@email_domain}")
    @registry_org = create(:registry_org, home_page: "http://#{@email_domain}", org: @org)
    @user = create(:user, email: "jane@#{@email_domain}", org: @org)
    visit root_path
  end

  it 'does not display bypass link for unknown user with a known email domain for an unshibbolized org', js: true do
    email = "anna@#{@email_domain}"
    fill_in 'Email address', with: email
    click_on 'Continue'

    expect(page).to have_text('New Account Sign Up')
    expect(find('#user_disabled_email').value).to eql(email)
    expect(find('#org_autocomplete_name').value).to eql(@org.name)
    expect(page).not_to have_text('Sign up with non SSO')
  end

  it 'handles unknown user with a known email domain for an shibbolized org', js: true do
    create_shibboleth_entity_id(org: @org)
    email = "anna@#{@email_domain}"
    fill_in 'Email address', with: email
    click_on 'Continue'

    expect(page).to have_text('New Account Sign Up')
    expect(find('#user_disabled_email').value).to eql(email)
    expect(page).to have_text(CGI.escapeHTML(@org.name))
    expect(page).to have_text('Sign up with Institution (SSO)')
    expect(page).to have_text('Sign up with non SSO')

    click_on 'Sign up with non SSO'

    expect(page).to have_text('New Account Sign Up')
    expect(find('#user_disabled_email').value).to eql(email)
    expect(find('#org_autocomplete_name').value).to eql(@org.name)

    within("form[action=\"#{user_registration_path}\"]") do
      fill_in 'First Name', with: Faker::Movies::StarWars.character.split.first
      fill_in 'Last Name', with: Faker::Movies::StarWars.character.split.last
      select_an_org('#sign-up-org', @non_ror_org.name, 'Institution')
      fill_in 'Password', with: SecureRandom.uuid
      # Need to use JS to set the accept terms label since dmptool-ui treats the
      # whole thing as a label and theis particular label has a URL so 'clicking' it
      # via Capybara results in going to the URL behind that link :/
      page.execute_script("document.getElementById('user_accept_terms').checked = true;")
      click_button 'Sign up'
    end

    expect(current_path).to eql(plans_path)
    expect(page).to have_text('Welcome')
    expect(page).to have_text('You are now ready to create your first DMP.')
  end
end
