# frozen_string_literal: true

require 'rails_helper'

describe 'user_mailer/new_api_client' do
  before do
    controller.prepend_view_path 'app/views/branded'
  end

  it 'renders correctly' do
    client = create(:api_client)
    user = create(:user)
    assign :name, user.name(false)
    assign :api_client, client

    render
    expect(rendered.include?('A new API registration')).to be(true)
    expect(rendered.include?('You can review the registration details')).to be(true)
    expect(rendered.include?(CGI.escapeHTML(user.name(false)))).to be(true)
    expect(rendered.include?(CGI.escapeHTML(client.name))).to be(true)
    expect(rendered.include?(CGI.escapeHTML(client.description))).to be(true)
    expect(rendered.include?(client.homepage)).to be(true)
    expect(rendered.include?(CGI.escapeHTML(client.contact_name))).to be(true)
    expect(rendered.include?(client.contact_email)).to be(true)
    expect(rendered.include?(client.redirect_uri)).to be(true)
    expect(rendered.include?(client.scopes.to_s)).to be(true)
    expect(rendered.include?('You can deactivate these credentials')).to be(true)
    expect(response).to render_template(partial: 'user_mailer/_email_signature')
  end

  it 'renders the correct message if no redirect_uri was defined' do
    client = create(:api_client, redirect_uri: nil)
    user = create(:user)
    assign :name, user.name(false)
    assign :api_client, client

    render
    expect(rendered.include?('The user did not provide a redirect_uri ')).to be(true)
  end
end
