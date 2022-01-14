# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Shibboleth Sign up via email and password', type: :feature do
  include DmptoolHelper
  include IdentifierHelper
  include AuthenticationHelper

  before(:each) do
    @email_domain = "foo.edu"
    @org = create(:org, contact_email: "#{Faker::Lorem.unique.word}@#{@email_domain}", managed: true)
    @registry_org = create(:registry_org, home_page: "http://#{@email_domain}", org: @org)
    @existing = create(:user, email: "#{Faker::Lorem.unique.word}@#{@email_domain}", org: @org)

    create_shibboleth_entity_id(org: @org)
    create_shibboleth_eppn(user: @existing)

    @user = build(:user, org: @org, email: "#{Faker::Lorem.unique.word}@#{@email_domain}")

    mock_blog
    visit root_path
    fill_in 'Email address', with: @user.email
    click_on 'Continue'
    expect(page).to have_text('New Account Sign Up')
  end

  scenario 'user authenticates with their IdP' do
    mock_shibboleth(user: @user)

    click_button 'Sign in with Institution to Continue'
    expect(page).to have_text('Mock Shibboleth IdP Sign in form')
    fill_in 'Email', with: @existing.email
    fill_in 'Password', with: SecureRandom.uuid
    click_button 'Sign in'

    expect(page).to have_text(_(''))

pp page.body

  end

  scenario 'user authenticates with their IdP but eppn does not match one on record' do

  end

  scenario 'Idp responds with error' do

  end
end
