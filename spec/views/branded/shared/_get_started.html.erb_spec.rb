# frozen_string_literal: true

require "rails_helper"

describe "shared/_get_started.html.erb" do
  before(:each) do
    @shib = "is affiliated with DMPTool."
    @login = "is not affiliated with DMPTool."
    @create = "If not affiliated and you need an account."
    controller.prepend_view_path "app/views/branded"
  end

  it "renders the correct sign in options when Shibboleth is not enabled" do
    Rails.configuration.x.shibboleth.enabled = false
    render
    expect(rendered.include?("Sign in options")).to eql(true)
    expect(rendered.include?(@shib)).to eql(false)
    expect(rendered.include?(@login)).to eql(true)
    expect(rendered.include?(@create)).to eql(true)
    expect(rendered.include?("Option 3")).to eql(false)
  end

  it "renders the correct sign in options when Shibboleth is enabled" do
    Rails.configuration.x.shibboleth.enabled = true
    render
    expect(rendered.include?("Sign in options")).to eql(true)
    expect(rendered.include?(@shib)).to eql(true)
    expect(rendered.include?(@login)).to eql(true)
    expect(rendered.include?(@create)).to eql(true)
    expect(rendered.include?("Option 3")).to eql(true)
  end

end
