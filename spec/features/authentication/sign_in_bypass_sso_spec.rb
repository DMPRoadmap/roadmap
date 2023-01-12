# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sign in and bypass SSO' do
  include Helpers::DmptoolHelper
  include Helpers::AutocompleteHelper
  include Helpers::IdentifierHelper

  before do
    @original_shib = Rails.configuration.x.shibboleth&.enabled
    @original_disco = Rails.configuration.x.shibboleth.use_filtered_discovery_service
    Rails.configuration.x.shibboleth&.enabled = true
    Rails.configuration.x.shibboleth.use_filtered_discovery_service = true
    mock_blog
    @pwd = SecureRandom.uuid

    @email_domain = 'foo.edu'
    @org = create(:org, name: 'Test Org', contact_email: "help-desk@#{@email_domain}")
    @plan = create(:plan, :creator)
    @user = @plan.owner
    @user.update(email: "jane@#{@email_domain}", org: @org,
                 password: @pwd, password_confirmation: @pwd)
    visit root_path
  end

  after do
    Rails.configuration.x.shibboleth.enabled = @original_shib
    Rails.configuration.x.shibboleth.use_filtered_discovery_service = @original_disco
  end

  it 'does not display bypass link for known user with an unshibbolized org', js: true do
    fill_in 'Email address', with: @user.email
    click_on 'Continue'

    expect(page).to have_text('Sign in')
    expect(find_by_id('user_disabled_email').value).to eql(@user.email)
    expect(find_by_id('user_password').value).to eql('')
    expect(page).not_to have_text('Sign in with non SSO')
  end

  it 'handles known user with an shibbolized org', js: true do
    create_shibboleth_entity_id(org: @org)
    fill_in 'Email address', with: @user.email
    click_on 'Continue'

    expect(page).to have_text('Sign in')
    expect(find_by_id('user_disabled_email').value).to eql(@user.email)
    expect(page).to have_text(CGI.escapeHTML(@org.name))
    expect(page).to have_text('Sign in with Institution (SSO)')
    expect(page).to have_text('Sign in with non SSO')

    click_on 'Sign in with non SSO'

    expect(page).to have_text('Sign in')
    expect(find_by_id('user_disabled_email').value).to eql(@user.email)
    expect(find_by_id('user_password').value).to eql('')

    within("form[action=\"#{user_session_path}\"]") do
      fill_in 'Password', with: @pwd
      click_button 'Sign in'
    end

    expect(current_path).to eql(plans_path)
    expect(page).to have_text('My Dashboard')
  end
end
