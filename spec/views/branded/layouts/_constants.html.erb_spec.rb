# frozen_string_literal: true

require "rails_helper"

describe "layouts/_constants.html.erb" do

  it "renders all of the constants properly" do
    controller.prepend_view_path "app/views/branded"
    render
    expect(rendered.include?("HOST")).to eql(true)
    expect(rendered.include?("PASSWORD_MIN_LENGTH")).to eql(true)
    expect(rendered.include?("PASSWORD_MAX_LENGTH")).to eql(true)
    expect(rendered.include?("MAX_NUMBER_ORG_URLS")).to eql(true)
    expect(rendered.include?("MAX_NUMBER_GUIDANCE_SELECTIONS")).to eql(true)
    expect(rendered.include?("REQUIRED_FIELD_TEXT")).to eql(true)
    expect(rendered.include?("SHOW_PASSWORD_MESSAGE")).to eql(true)
    expect(rendered.include?("SHOW_SELECT_ORG_MESSAGE")).to eql(true)
    expect(rendered.include?("SHOW_OTHER_ORG_MESSAGE")).to eql(true)
    expect(rendered.include?("VALIDATION_MESSAGE_PASSWORDS_MATCH")).to eql(true)
    expect(rendered.include?("PLAN_VISIBILITY_WHEN_TEST")).to eql(true)
    expect(rendered.include?("PLAN_VISIBILITY_WHEN_NOT_TEST")).to eql(true)
    expect(rendered.include?("PLAN_VISIBILITY_WHEN_NOT_TEST_TOOLTIP")).to eql(true)
    expect(rendered.include?("SHIBBOLETH_DISCOVERY_SERVICE_HIDE_LIST")).to eql(true)
    expect(rendered.include?("SHIBBOLETH_DISCOVERY_SERVICE_SHOW_LIST")).to eql(true)
    expect(rendered.include?("NO_TEMPLATE_FOUND_ERROR")).to eql(true)
    expect(rendered.include?("NEW_PLAN_DISABLED_TOOLTIP")).to eql(true)
    expect(rendered.include?("OPENS_IN_A_NEW_WINDOW_TEXT")).to eql(true)
    expect(rendered.include?("AJAX_LOADING")).to eql(true)
    expect(rendered.include?("AJAX_UNABLE_TO_LOAD_TEMPLATE_SECTION")).to eql(true)
    expect(
      rendered.include?("AJAX_UNABLE_TO_LOAD_TEMPLATE_SECTION_QUESTION")
    ).to eql(true)
    expect(rendered.include?("AUTOCOMPLETE_ARIA_HELPER")).to eql(true)
    expect(rendered.include?("AUTOCOMPLETE_ARIA_HELPER_EMPTY")).to eql(true)
    expect(rendered.include?("js-constants")).to eql(true)
  end

end
