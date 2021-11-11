# frozen_string_literal: true

require 'rails_helper'

describe 'shared/authentication/_shib_sign_in_form.html.erb' do
  it 'renders nothing if shibboleth is not enabled' do
    Rails.configuration.x.shibboleth.enabled = false
    render
    expect(rendered).to eql("\n")
  end

  it 'renders the federated discovery service button when :use_filtered_discovery_service is false' do
    Rails.configuration.x.shibboleth.enabled = true
    Rails.configuration.x.shibboleth.use_filtered_discovery_service = false
    render

    expect(rendered.include?('Sign in with your institutional credentials')).to eql(true)

    expect(response).not_to render_template(partial: 'shared/_org_autocomplete')
    expect(rendered.include?('Go')).to eql(false)

    expect(rendered.include?('data-method="post"')).to eql(true)

    expect(rendered.include?('shibboleth_id')).to eql(false)
  end

  it 'renders the Org autocomplete when the :use_filtered_discovery_service is true in config' do
    Rails.configuration.x.shibboleth.enabled = true
    Rails.configuration.x.shibboleth.use_filtered_discovery_service = true
    render

    expect(rendered.include?('Sign in with your institutional credentials')).to eql(true)

    expect(response).to render_template(partial: 'shared/_org_autocomplete')
    expect(rendered.include?('Go')).to eql(true)

    expect(rendered.include?('data-method="post"')).to eql(false)

    expect(rendered.include?('shibboleth_id')).to eql(false)
  end
end
