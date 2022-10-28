# frozen_string_literal: true

require 'rails_helper'

describe 'layouts/_header.html.erb' do
  include Helpers::DmptoolHelper

  before do
    controller.prepend_view_path 'app/views/branded'
    @lang = Language.default.abbreviation
  end

  it 'renders properly when user is not signed in' do
    render
    expect(rendered.include?('<header class="c-header">')).to be(true)
    expect(rendered.include?('class="c-logo-dmptool"')).to be(true)

    expect(rendered.include?('class="c-navtoggle"')).to be(true)
    expect(rendered.include?('class="c-headernav"')).to be(true)
    expect(rendered.include?('Funder Requirements')).to be(true)
    expect(rendered.include?('Public DMPs')).to be(true)
    expect(rendered.include?('Help')).to be(true)

    expect(rendered.include?('class="c-user-profile"')).to be(false)
    expect(rendered.include?('class="c-user-profile__button"')).to be(false)
    expect(rendered.include?('class="c-user-profile__menu"')).to be(false)
    expect(rendered.include?('Edit profile')).to be(false)
    expect(rendered.include?('3rd party applications')).to be(false)
    expect(rendered.include?('Developer tools')).to be(false)
    expect(rendered.include?('Sign out')).to be(false)

    expect(rendered.include?('class="c-language')).to be(true)
    expect(rendered.include?('id="js-language__button"')).to be(true)
    expect(rendered.include?('id="js-language__menu"')).to be(true)
    expect(rendered.include?(@lang)).to be(true)

    expect(response).not_to render_template(partial: 'layouts/_sub_header')
  end

  it 'renders properly when user is signed in' do
    sign_in(create(:user))
    render
    expect(rendered.include?('<header class="c-header">')).to be(true)
    expect(rendered.include?('class="c-logo-dmptool"')).to be(true)

    expect(rendered.include?('class="c-navtoggle"')).to be(true)
    expect(rendered.include?('class="c-headernav"')).to be(true)
    expect(rendered.include?('Funder Requirements')).to be(true)
    expect(rendered.include?('Public DMPs')).to be(true)
    expect(rendered.include?('Help')).to be(true)

    expect(rendered.include?('class="c-profile')).to be(true)
    expect(rendered.include?('id="js-user-profile__button"')).to be(true)
    expect(rendered.include?('id="js-user-profile__menu"')).to be(true)
    expect(rendered.include?('Edit profile')).to be(true)
    expect(rendered.include?('3rd party applications')).to be(true)
    expect(rendered.include?('Developer tools')).to be(true)
    expect(rendered.include?('Sign in')).to be(false)
    expect(rendered.include?('Sign out')).to be(true)

    expect(rendered.include?('class="c-language')).to be(true)
    expect(rendered.include?('id="js-language__button"')).to be(true)
    expect(rendered.include?('id="js-language__menu"')).to be(true)
    expect(rendered.include?(@lang)).to be(true)

    expect(response).to render_template(partial: 'layouts/_sub_header')
  end
end
