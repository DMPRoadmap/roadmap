# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sign in/up via email entry' do
  include Helpers::DmptoolHelper
  include Helpers::AutocompleteHelper
  include Helpers::IdentifierHelper

  before do
    @original_shib = Rails.configuration.x.shibboleth&.enabled
    @original_disco = Rails.configuration.x.shibboleth.use_filtered_discovery_service
    Rails.configuration.x.shibboleth&.enabled = true
    Rails.configuration.x.shibboleth.use_filtered_discovery_service = true
    mock_blog
    @email_domain = 'foo.edu'
    @org = create(:org, name: 'Test Org', contact_email: "help-desk@#{@email_domain}")
    @registry_org = create(:registry_org, name: 'Test Registry Org', home_page: "http://#{@email_domain}", org: @org)
    @user = create(:user, email: "jane@#{@email_domain}", org: @org)
    visit root_path
  end

  after do
    Rails.configuration.x.shibboleth.enabled = @original_shib
    Rails.configuration.x.shibboleth.use_filtered_discovery_service = @original_disco
  end

  it 'displays an error if no email is provided', js: true do
    within("form[action=\"#{user_session_path}\"]") do
      expect { find('.is-invalid[id="sign-in-sign-up-email"]') }.to raise_error(Capybara::ElementNotFound)
      click_button 'Continue'
      expect(find('.is-invalid[id="sign-in-sign-up-email"]').present?).to be(true)
    end
  end

  it 'handles known user with an unshibbolized org', js: true do
    fill_in 'Email address', with: @user.email
    click_on 'Continue'

    expect(page).to have_text('Sign in')
    expect(find_by_id('user_disabled_email').value).to eql(@user.email)
    expect(find_by_id('user_password').value).to eql('')
  end

  it 'handles known user with a shibbolized org', js: true do
    create_shibboleth_entity_id(org: @org)
    fill_in 'Email address', with: @user.email
    click_on 'Continue'
    expect(page).to have_text('Sign in')
    expect(find_by_id('user_disabled_email').value).to eql(@user.email)
    expect(page).to have_text(CGI.escapeHTML(@org.name)), page.body
    expect(page).to have_text('Sign in with Institution (SSO)')
    expect(page).to have_text('Sign in with non SSO')
  end

  it 'handles unknown user with an unknown email', js: true do
    fill_in 'Email address', with: Faker::Internet.unique.email
    click_on 'Continue'

    expect(page).to have_text('New Account Sign Up')
  end

  it 'handles unknown user with a known email domain for an unshibbolized org', js: true do
    email = "anna@#{@email_domain}"
    fill_in 'Email address', with: email
    click_on 'Continue'

    expect(page).to have_text('New Account Sign Up')
    expect(find_by_id('user_disabled_email').value).to eql(email)
    expect(find_by_id('org_autocomplete_name').value).to eql(@org.name)
  end

  it 'handles unknown user with a known email domain for an shibbolized org', js: true do
    create_shibboleth_entity_id(org: @org)
    email = "anna@#{@email_domain}"
    fill_in 'Email address', with: email
    click_on 'Continue'

    expect(page).to have_text('New Account Sign Up')
    expect(find_by_id('user_disabled_email').value).to eql(email)
    expect(page).to have_text(CGI.escapeHTML(@org.name))
    expect(page).to have_text('Sign up with Institution (SSO)')
    expect(page).to have_text('Sign up with non SSO')
  end

  it 'handles known user with a shibbolized org and multiple similar orgs', js: true do
    create_shibboleth_entity_id(org: @org)
    similar_org = create(:org, contact_email: "similar@zoo#{@email_domain}")
    create_shibboleth_entity_id(org: similar_org)
    create(:registry_org, home_page: "similar@xyz#{@email_domain}/home/index.html")
    fill_in 'Email address', with: @user.email
    click_on 'Continue'

    expect(page).to have_text('Sign in')
    expect(find_by_id('user_disabled_email').value).to eql(@user.email)
    expect(page).to have_text(CGI.escapeHTML(@org.name)), page.body
    expect(page).to have_text('Sign in with Institution (SSO)')
    expect(page).to have_text('Sign in with non SSO')
  end
end
