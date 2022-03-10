# frozen_string_literal: true

require 'rails_helper'

describe 'user_mailer/new_api_client' do
  before(:each) do
    controller.prepend_view_path 'app/views/branded'
  end

  it 'renders correctly' do
    client = create(:api_client)
    user = create(:user)
    assign :name,  user.name(false)
    assign :api_client, client

    render
    expect(rendered.include?('A new API registration')).to eql(true)
    expect(rendered.include?('You can review the registration details')).to eql(true)
    expect(rendered.include?(CGI.escapeHTML(user.name(false)))).to eql(true)
    expect(rendered.include?(CGI.escapeHTML(client.name))).to eql(true)
    expect(rendered.include?(CGI.escapeHTML(client.description))).to eql(true)
    expect(rendered.include?(client.homepage)).to eql(true)
    expect(rendered.include?(CGI.escapeHTML(client.contact_name))).to eql(true)
    expect(rendered.include?(client.contact_email)).to eql(true)
    expect(rendered.include?(client.redirect_uri)).to eql(true)
    expect(rendered.include?(client.scopes.to_s)).to eql(true)
    expect(rendered.include?('You can deactivate these credentials')).to eql(true)
    expect(response).to render_template(partial: 'user_mailer/_email_signature')
  end
  it 'renders the correct message if no redirect_uri was defined' do
    client = create(:api_client, redirect_uri: nil)
    user = create(:user)
    assign :name,  user.name(false)
    assign :api_client, client

    render
    expect(rendered.include?('The user did not provide a redirect_uri ')).to eql(true)
  end
end
