# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Shibboleth Sign in / Sign up' do
  include Helpers::DmptoolHelper
  include Helpers::IdentifierHelper
  include Helpers::AuthenticationHelper

  before do
    @original_shib = Rails.configuration.x.shibboleth&.enabled
    @original_disco = Rails.configuration.x.shibboleth.use_filtered_discovery_service
    Rails.configuration.x.shibboleth&.enabled = true
    Rails.configuration.x.shibboleth.use_filtered_discovery_service = true
    @email_domain = 'foo.edu'
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

    expect(page).to have_text(_('New Account Sign Up'))
    expect(page).to have_text(@org.name)
  end

  after do
    Rails.configuration.x.shibboleth.enabled = @original_shib
    Rails.configuration.x.shibboleth.use_filtered_discovery_service = @original_disco
  end

  it 'user authenticates with their IdP' do
    mock_shibboleth(user: @existing)
    click_button 'Sign up with Institution (SSO)'
    expect(page).to have_text(_('Successfully signed in'))
    unmock_shibboleth
  end

  it 'user authenticates with their IdP but eppn does not match one on record' do
    mock_shibboleth(user: @user)
    click_button 'Sign up with Institution (SSO)'
    expect(page).to have_text(_('It looks like this is your first time signing in.'))
    expect(find("input[value=\"#{@user.org.id}\"]", visible: false).present?).to be(true)
    expect(find("input[value=\"#{@user.email}\"]").present?).to be(true)
    expect(find("input[value=\"#{CGI.escapeHTML(@user.firstname.downcase.humanize)}\"]").present?).to be(true)
    expect(find("input[value=\"#{CGI.escapeHTML(@user.surname.downcase.humanize)}\"]").present?).to be(true)
    unmock_shibboleth
  end

  it 'user authenticates with their IdP but entityID matches multiple Orgs' do
    mock_shibboleth(user: @user)
    scheme = IdentifierScheme.where(name: 'shibboleth').first
    id = Identifier.where(identifiable_id: @org.id, identifiable_type: 'Org', identifier_scheme_id: scheme.id)
    other_org = create(:org)
    Identifier.create(identifiable: other_org, identifier_scheme_id: scheme.id,
                      value: @org.identifier_for_scheme(scheme: scheme))
    click_button 'Sign up with Institution (SSO)'
    expect(page).to have_text(_('It looks like this is your first time signing in.'))
    expect(find("input[value=\"#{@user.org.id}\"]", visible: false).present?).to be(true)
    expect(find("input[value=\"#{@user.email}\"]").present?).to be(true)
    expect(find("input[value=\"#{CGI.escapeHTML(@user.firstname.downcase.humanize)}\"]").present?).to be(true)
    expect(find("input[value=\"#{CGI.escapeHTML(@user.surname.downcase.humanize)}\"]").present?).to be(true)
    unmock_shibboleth
  end

  it 'Idp responds with error' do
    mock_shibboleth(user: @user, success: false)
    click_button 'Sign up with Institution (SSO)'
    expect(page).to have_text(_('Unable to authenticate!'))
  end
end
