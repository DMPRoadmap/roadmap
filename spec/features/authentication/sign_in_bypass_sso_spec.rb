# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sign in and bypass SSO', type: :feature do
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

  it 'does not display bypass link for known user with an unshibbolized org', js: true do
    fill_in 'Email address', with: @user.email
    click_on 'Continue'

    expect(page).to have_text('Sign in')
    expect(find('#user_disabled_email').value).to eql(@user.email)
    expect(find('#user_password').value).to eql('')
    expect(page).not_to have_text('Sign in with non SSO')
  end

  it 'handles known user with an shibbolized org', js: true do
    create_shibboleth_entity_id(org: @org)
    fill_in 'Email address', with: @user.email
    click_on 'Continue'

    expect(page).to have_text('Sign in')
    expect(find('#user_disabled_email').value).to eql(@user.email)
    expect(page).to have_text(CGI.escapeHTML(@org.name))
    expect(page).to have_text('Sign in with Institution (SSO)')
    expect(page).to have_text('Sign in with non SSO')

    click_on 'Sign in with non SSO'

    expect(page).to have_text('Sign in')
    expect(find('#user_disabled_email').value).to eql(@user.email)
    expect(find('#user_password').value).to eql('')

    within("form[action=\"#{user_session_path}\"]") do
      fill_in 'Password', with: @pwd
      click_button 'Sign in'
    end

    expect(current_path).to eql(plans_path)
    expect(page).to have_text('My Dashboard')
  end
end