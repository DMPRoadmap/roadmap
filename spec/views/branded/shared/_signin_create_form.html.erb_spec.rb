# frozen_string_literal: true

require "rails_helper"

describe "shared/_signin_create_form.html.erb" do
  before(:each) do
    controller.prepend_view_path "app/views/branded"
  end

  it "renders the Signin / Create Account tabs" do
    render
    expect(rendered.include?("Sign in")).to eql(true)
    expect(rendered.include?("Create account")).to eql(true)
  end

  it "renders the form partials" do
    render
    expect(response).to render_template(partial: "shared/_sign_in_form")
    expect(response).to render_template(partial: "shared/_signin_create_form")
  end

end
