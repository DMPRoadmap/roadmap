# frozen_string_literal: true

require "rails_helper"

describe "shared/_sign_in_form.html.erb" do
  before(:each) do
    controller.prepend_view_path "app/views/branded"
  end

  it "renders the sign in form" do
    render
    expect(rendered.include?("Email")).to eql(true)
    expect(rendered.include?("Password")).to eql(true)
    expect(rendered.include?("Forgot password?")).to eql(true)
    expect(rendered.include?("Remember email")).to eql(true)
    expect(rendered.include?("Sign in")).to eql(true)
  end

  it "does NOT render the Institutional Credentials button" do
    render
    expect(rendered.include?("institutional credentials")).to eql(false)
  end

end
