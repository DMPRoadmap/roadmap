# frozen_string_literal: true

require 'rails_helper'

describe 'user_mailer/notify_administrators' do
  before(:each) do
    controller.prepend_view_path 'app/views/branded'
  end

  it 'renders correctly' do
    message = Faker::Lorem.paragraph
    assign :message, message

    render
    expect(rendered.include?('An error has been reported from')).to eql(true)
    expect(rendered.include?(message)).to eql(true)
    expect(response).to render_template(partial: 'user_mailer/_email_signature')
  end
end
