# frozen_string_literal: true

require 'rails_helper'

describe 'users/shared/_login_header' do
  include Helpers::DmptoolHelper

  it 'renders correctly' do
    controller.prepend_view_path 'app/views/branded'

    title = Faker::Music::PearlJam.album
    render partial: '/users/shared/login_header', locals: { title: title }

    expect(rendered.include?('class="c-login__header"')).to be(true)
    expect(rendered.include?("<h2>#{CGI.escapeHTML(title)}")).to be(true)
    expect(rendered.include?('c-login__invalid-notification')).to be(true)
  end
end
