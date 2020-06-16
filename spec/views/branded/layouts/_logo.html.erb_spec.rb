# frozen_string_literal: true

require "rails_helper"

describe "layouts/_logo.html.erb" do

  before(:each) do
    controller.prepend_view_path "app/views/branded"
    # stub the logo method
    @org = create(:org)
    logo = OpenStruct.new({ present?: true })
    logo.stubs(:thumb).returns(OpenStruct.new({ url: Faker::Internet.url }))
    Org.any_instance.stubs(:logo).returns(logo)
  end

  it "renders correctly when user is NOT logged in" do
    render
    expect(rendered.include?("org-logo")).to eql(false)
    expect(rendered.include?("app-logo")).to eql(true)
    expect(rendered.include?("DMPTool_logo_blue_shades_v1b3b.svg")).to eql(true)
  end

  it "renders correctly when user is logged in" do
    sign_in create(:user, org: @org)
    render

p rendered

    expect(rendered.include?("org-logo")).to eql(true)
    expect(rendered.include?(@org.name)).to eql(true)
    expect(rendered.include?("app-logo")).to eql(false)
    expect(rendered.include?("DMPTool_logo_blue_shades_v1b3b.svg")).to eql(false)
  end

end
