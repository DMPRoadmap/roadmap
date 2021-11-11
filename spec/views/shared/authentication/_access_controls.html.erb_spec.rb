# frozen_string_literal: true

require 'rails_helper'

describe 'shared/authentication/_access_controls.html.erb' do
  it 'renders both tabs' do
    render
    expect(rendered.include?('class="sign-in"')).to eql(true)
    expect(rendered.include?('href="#sign-in-form"')).to eql(true)
    expect(rendered.include?('href="#create-account-form"')).to eql(true)
    expect(rendered.include?('id="sign-in-form"')).to eql(true)
    expect(rendered.include?('id="create-account-form"')).to eql(true)
  end

  it 'renders the email + password sign in form if no sign_in_options defined in config' do
    Rails.configuration.x.sign_in_options = nil
    render
    expect(response).to render_template(partial: 'shared/authentication/_sign_in_form')
  end

  # SSO via a Federatation discovery service (e.g. UK Federation)
  it 'renders the shib_sign_in_form if it is specified in the config' do
    Rails.configuration.x.sign_in_options = ['shared/authentication/shib_sign_in_form']
    render
    expect(response).to render_template(partial: 'shared/authentication/_shib_sign_in_form')
  end
end
