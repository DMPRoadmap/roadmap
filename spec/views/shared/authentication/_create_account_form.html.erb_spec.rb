# frozen_string_literal: true

require 'rails_helper'

describe 'shared/authentication/_create_account_form.html.erb' do
  include SessionsHelper

  it 'renders the form' do
    Rails.configuration.x.recaptcha.enabled = true

    assign :resource, User.new
    render
    expect(rendered.include?('id="create_account_form"')).to eql(true)
    expect(rendered.include?('id="user_external_api_token_acess_token"')).to eql(false)
    expect(rendered.include?('id="new_user_firstname"')).to eql(true)
    expect(rendered.include?('id="new_user_surname"')).to eql(true)
    expect(rendered.include?('id="new_user_email"')).to eql(true)
    expect(rendered.include?('name="org_autocomplete[name]"')).to eql(true)
    expect(rendered.include?('id="new_user_password"')).to eql(true)
    expect(rendered.include?('id="passwords_toggle_sign_up"')).to eql(true)
    expect(rendered.include?('id="new_user_accept_terms"')).to eql(true)
    expect(rendered.include?('Security check')).to eql(true)
    expect(rendered.include?('Create account')).to eql(true)

    expect(response).to render_template(partial: 'shared/_org_autocomplete')
  end

  it 'does not display the Recaptcha if it is disabled in the config' do
    Rails.configuration.x.recaptcha.enabled = false

    assign :resource, User.new
    render
    expect(rendered.include?('Security check')).to eql(false)
  end

  it 'renders properly if part of an OAuth2 authorization workflow' do
    api_client = create(:api_client)
    user = create(:user)
    create(:external_api_access_token, external_service_name: api_client.name, user: user)
    assign :resource, user.reload
    render

    expect(rendered.include?('id="user_external_api_token_acess_token"')).to eql(true)
  end

  it 'renders properly if part of a new user Omniauth workflow' do
    scheme = create(:identifier_scheme, name: 'shibboleth')
    org = create(:org, managed: true)
    org.identifiers << create(:identifier, identifiable: org, identifier_scheme: scheme)
    user = build(:user, org: org)
    assign :resource, user
    session['devise.shibboleth_data'] = mock_omniauth_call(scheme.name, user)
    render

    expect(rendered.include?(user.firstname)).to eql(true)
    expect(rendered.include?(user.surname)).to eql(true)
    expect(rendered.include?(user.email)).to eql(true)
    expect(rendered.include?(user.org.name)).to eql(true)
    expect(rendered.include?('type="hidden" name="org_autocomplete[name]"')).to eql(true)
    expect(rendered.include?('class="form-control hidden" type="password"')).to eql(true)
    expect(rendered.include?('id="passwords_toggle_sign_up"')).to eql(false)
  end
end
