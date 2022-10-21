# frozen_string_literal: true

require 'rails_helper'

describe 'users/shared/_links' do
  include Helpers::DmptoolHelper

  it 'renders correctly when showing both back button and contact us message' do
    controller.prepend_view_path 'app/views/branded'

    user = build(:user, firstname: nil, surname: nil)
    user.valid?
    render partial: '/users/shared/links',
           locals: { show_back_button: true, show_contact_us: true }

    expect(rendered.include?('Go back')).to eql(true)
    expect(rendered.include?('class="c-login__footer"')).to eql(true)
    expect(rendered.include?('Problems signing in?')).to eql(true)
  end
  it 'renders correctly when showing the back button but not the contact us message' do
    controller.prepend_view_path 'app/views/branded'

    user = build(:user, firstname: nil, surname: nil)
    user.valid?
    render partial: '/users/shared/links',
           locals: { show_back_button: true, show_contact_us: false }

    expect(rendered.include?('Go back')).to eql(true)
    expect(rendered.include?('class="c-login__footer"')).to eql(false)
    expect(rendered.include?('Problems signing in?')).to eql(false)
  end
  it 'renders correctly when showing contact us message but not the back button' do
    controller.prepend_view_path 'app/views/branded'

    user = build(:user, firstname: nil, surname: nil)
    user.valid?
    render partial: '/users/shared/links',
           locals: { show_back_button: false, show_contact_us: true }

    expect(rendered.include?('Go back')).to eql(false)
    expect(rendered.include?('class="c-login__footer"')).to eql(true)
    expect(rendered.include?('Problems signing in?')).to eql(true)
  end
  it 'renders correctly when showing neither the back button or contact us message' do
    controller.prepend_view_path 'app/views/branded'

    user = build(:user, firstname: nil, surname: nil)
    user.valid?
    render partial: '/users/shared/links',
           locals: { show_back_button: false, show_contact_us: false }

    expect(rendered.include?('Go back')).to eql(false)
    expect(rendered.include?('class="c-login__footer"')).to eql(false)
    expect(rendered.include?('Problems signing in?')).to eql(false)
  end
end
