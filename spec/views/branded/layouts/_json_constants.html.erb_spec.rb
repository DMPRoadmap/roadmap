# frozen_string_literal: true

require 'rails_helper'

describe 'layouts/_json_constants.html.erb' do
  it 'renders all of the constants properly' do
    controller.prepend_view_path 'app/views/branded'
    render
    expect(rendered.include?('HOST')).to be(true)
    expect(rendered.include?('PASSWORD_MIN_LENGTH')).to be(true)
    expect(rendered.include?('PASSWORD_MAX_LENGTH')).to be(true)
    expect(rendered.include?('MAX_NUMBER_ORG_URLS')).to be(true)
    expect(rendered.include?('MAX_NUMBER_GUIDANCE_SELECTIONS')).to be(true)

    expect(rendered.include?('REQUIRED_FIELD_TEXT')).to be(true)
    expect(rendered.include?('SHOW_PASSWORD_MESSAGE')).to be(true)
    expect(rendered.include?('SHOW_SELECT_ORG_MESSAGE')).to be(true)
    expect(rendered.include?('SHOW_OTHER_ORG_MESSAGE')).to be(true)

    expect(rendered.include?('PLAN_VISIBILITY_WHEN_TEST')).to be(true)
    expect(rendered.include?('PLAN_VISIBILITY_WHEN_NOT_TEST')).to be(true)
    expect(rendered.include?('PLAN_VISIBILITY_WHEN_NOT_TEST_TOOLTIP')).to be(true)

    expect(rendered.include?('NO_TEMPLATE_FOUND_ERROR')).to be(true)
    expect(rendered.include?('NEW_PLAN_DISABLED_TOOLTIP')).to be(true)

    expect(rendered.include?('AJAX_LOADING')).to be(true)
    expect(rendered.include?('AJAX_UNABLE_TO_LOAD_TEMPLATE_SECTION')).to be(true)
    expect(rendered.include?('AJAX_UNABLE_TO_LOAD_TEMPLATE_SECTION_QUESTION')).to be(true)

    expect(rendered.include?('OPENS_IN_A_NEW_WINDOW_TEXT')).to be(true)

    expect(rendered.include?('AUTOCOMPLETE_ARIA_HELPER')).to be(true)
    expect(rendered.include?('AUTOCOMPLETE_ARIA_HELPER_EMPTY')).to be(true)

    expect(rendered.include?('CURRENT_LOCALE')).to be(true)

    expect(rendered.include?('MORE_INFO')).to be(true)
    expect(rendered.include?('LESS_INFO')).to be(true)

    expect(rendered.include?('ACQUIRING_DMP_ID')).to be(true)

    expect(rendered.include?('FIELD')).to be(true)
    expect(rendered.include?('FIELDS')).to be(true)

    expect(rendered.include?('SIGN_IN_UP_BLANK_CHECKBOX')).to be(true)
    expect(rendered.include?('SIGN_IN_UP_BLANK_EMAIL')).to be(true)
    expect(rendered.include?('SIGN_IN_UP_BLANK_FIELD')).to be(true)
    expect(rendered.include?('SIGN_IN_UP_BLANK_PASSWORD')).to be(true)

    expect(rendered.include?('SIGN_IN_UP_INVALID_EMAIL')).to be(true)
    expect(rendered.include?('SIGN_IN_UP_INVALID_FORM')).to be(true)
    expect(rendered.include?('SIGN_IN_UP_INVALID_PASSWORD')).to be(true)

    expect(rendered.include?('SIGN_IN_UP_VALID_FORM')).to be(true)

    expect(rendered.include?('js-constants')).to be(true)
  end
end
