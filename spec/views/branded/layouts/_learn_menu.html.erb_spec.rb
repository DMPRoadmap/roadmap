# frozen_string_literal: true

require "rails_helper"

describe "layouts/_learn_menu.html.erb" do

  it "renders correctly" do
    controller.prepend_view_path "app/views/branded"
    render
    expect(rendered.include?("learn-menu-button")).to eql(true)
    expect(rendered.include?("Funder Requirements")).to eql(true)
    expect(rendered.include?("Public Plans")).to eql(true)
    expect(rendered.include?("Participating Institutions")).to eql(true)
    expect(rendered.include?("FAQ")).to eql(true)
    expect(rendered.include?("Quick Start Guide")).to eql(true)
    expect(rendered.include?("Data Management General Guidance")).to eql(true)
    expect(rendered.include?("For Administrators")).to eql(true)
    expect(rendered.include?("Promote the DMPTool")).to eql(true)
  end

end
