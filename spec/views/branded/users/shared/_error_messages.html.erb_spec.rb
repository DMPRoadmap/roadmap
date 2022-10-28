# frozen_string_literal: true

require 'rails_helper'

describe 'users/shared/_error_messages' do
  include Helpers::DmptoolHelper

  it 'renders our version of the page' do
    controller.prepend_view_path 'app/views/branded'

    user = build(:user, firstname: nil, surname: nil)
    user.valid?
    render partial: '/users/shared/error_messages', locals: { resource: user }

    expect(rendered.include?('Firstname can\'t be blank')).to be(true)
    expect(rendered.include?('<br>')).to be(true)
    expect(rendered.include?('Surname can\'t be blank')).to be(true)
  end

  it 'renders properly when there are no errors' do
    controller.prepend_view_path 'app/views/branded'

    user = build(:user)
    user.valid?
    render partial: '/users/shared/error_messages', locals: { resource: user }

    expect(rendered).to eql('')
  end
end
