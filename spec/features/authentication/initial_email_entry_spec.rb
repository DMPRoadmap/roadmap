# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sign in/up via email entry', type: :feature do
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

  it 'displays an error if no email is provided', js: true do
    within("form[action=\"#{user_session_path}\"]") do
      expect { find('.is-invalid[id="sign-in-sign-up-email"]') }.to raise_error(Capybara::ElementNotFound)
      click_button 'Continue'
      expect(find('.is-invalid[id="sign-in-sign-up-email"]').present?).to eql(true)
    end
  end

  it 'handles known user with an unshibbolized org', js: true do
    fill_in 'Email address', with: @user.email
    click_on 'Continue'

    expect(page).to have_text('Sign in')
    expect(find('#user_disabled_email').value).to eql(@user.email)
    expect(find('#user_password').value).to eql('')
  end

  it 'handles known user with an shibbolized org', js: true do
    create_shibboleth_entity_id(org: @org)
    fill_in 'Email address', with: @user.email
    click_on 'Continue'

    expect(page).to have_text('Sign in')
    expect(find('#user_disabled_email').value).to eql(@user.email)
    expect(page).to have_text('Your address is associated with:')
    expect(page).to have_text(CGI.escapeHTML(@org.name))
    expect(page).to have_text('Sign in with Institution to Continue')
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
    expect(find('#user_disabled_email').value).to eql(email)
    expect(find('#org_autocomplete_name').value).to eql(@org.name)
  end

  it 'handles unknown user with a known email domain for an shibbolized org', js: true do
    create_shibboleth_entity_id(org: @org)
    email = "anna@#{@email_domain}"
    fill_in 'Email address', with: email
    click_on 'Continue'

    expect(page).to have_text('New Account Sign Up')
    expect(find('#user_disabled_email').value).to eql(email)
    expect(page).to have_text('Your address is associated with:')
    expect(page).to have_text(CGI.escapeHTML(@org.name))
    expect(page).to have_text('Sign in with Institution to Continue')
  end

  it 'handles known user with a shibbolized org and multiple similar orgs', js: true do
    create_shibboleth_entity_id(org: @org)
    similar_org = create(:org, contact_email: "similar@z.#{@email_domain}")
    create_shibboleth_entity_id(org: similar_org)
    create(:registry_org, home_page: "similar@xyz.#{@email_domain}/home/index.html")
    fill_in 'Email address', with: @user.email
    click_on 'Continue'

    expect(page).to have_text('Sign in')
    expect(find('#user_disabled_email').value).to eql(@user.email)
    expect(page).to have_text('Your address is associated with:')
    expect(page).to have_text(CGI.escapeHTML(@org.name))
    expect(page).to have_text('Sign in with Institution to Continue')
  end
end
