# frozen_string_literal: true

require 'rails_helper'

describe 'users/mailer/reset_password_instructions' do
  before do
    controller.prepend_view_path 'app/views/branded'
    Rails.configuration.x.organisation.helpdesk_email = Faker::Internet.unique.email
    Rails.configuration.x.organisation.contact_us_url = nil
  end

  it 'renders correctly' do
    user = create(:user)
    token = SecureRandom.uuid

    assign :resource, user
    assign :token, token

    render
    expect(rendered.include?("Hello #{user.email}")).to be(true)
    expect(rendered.include?('Someone has requested a link to change')).to be(true)
    expect(rendered.include?('Change my password')).to be(true)
    expect(rendered.include?(token)).to be(true)
    expect(rendered.include?('All the best')).to be(true)
    expect(rendered.include?('Please do not reply to this email.')).to be(true)
  end
end
