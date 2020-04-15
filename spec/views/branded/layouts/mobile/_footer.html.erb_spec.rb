# frozen_string_literal: true

require "rails_helper"

describe "layouts/mobile/_footer.html.erb" do

  before(:each) do
    controller.prepend_view_path "app/views/branded"
  end

  it "renders our version of the page" do
    Rails.configuration.x.dmptool.version = Faker::Number.number
    render
    expect(rendered.include?("About")).to eql(true)
    expect(rendered.include?("Terms of use")).to eql(true)
    expect(rendered.include?("Privacy statement")).to eql(true)
    expect(rendered.include?("Accessibility")).to eql(true)
    expect(rendered.include?("Github")).to eql(true)
    expect(rendered.include?("Contact us")).to eql(true)
    expect(rendered.include?("Twitter")).to eql(true)
    expect(rendered.include?("RSS")).to eql(true)
    expect(rendered.include?("DMPTool_logo_blue_shades_v1b3b_no_tag.svg")).to eql(true)
    expect(rendered.include?("DMPTool is a service of")).to eql(true)
    expect(rendered.include?("The Regents of the University of California")).to eql(true)
    expect(rendered.include?("Version:")).to eql(true)
  end

end
