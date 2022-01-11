# frozen_string_literal: true

require 'rails_helper'

describe 'users/shared/_login_header' do
  include DmptoolHelper

  it 'renders correctly' do
    controller.prepend_view_path 'app/views/branded'

    title = Faker::Music::PearlJam.album
    render partial: '/users/shared/login_header', locals: { title: title }

    expect(rendered.include?('class="c-login__header"')).to eql(true)
    expect(rendered.include?("<h2>#{title}")).to eql(true)
    expect(rendered.include?('c-login__invalid-notification')).to eql(true)
  end
end
