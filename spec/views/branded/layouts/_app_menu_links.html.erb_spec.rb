# frozen_string_literal: true

require "rails_helper"

describe "layouts/_app_menu_links.html.erb" do

  before(:each) do
    controller.prepend_view_path "app/views/branded"
  end

  it "renders correctly for a regular user" do
    sign_in create(:user)
    render
    expect(rendered.include?("My Dashboard")).to eql(true)
    expect(rendered.include?("Create plan")).to eql(true)
    expect(rendered.include?("Admin Features")).to eql(false)
  end

  it "renders correctly for a org admin" do
    sign_in create(:user, :org_admin)
    render
    expect(rendered.include?("My Dashboard")).to eql(true)
    expect(rendered.include?("Create plan")).to eql(true)
    expect(rendered.include?("Admin Features")).to eql(true)
    expect(rendered.include?("Organisations")).to eql(false)
    expect(rendered.include?("Organisation details")).to eql(true)
    expect(rendered.include?("Users")).to eql(true)
    expect(rendered.include?("Plans")).to eql(true)
    expect(rendered.include?("Usage")).to eql(true)
    expect(rendered.include?("Templates")).to eql(true)
    expect(rendered.include?("Guidance")).to eql(true)
    expect(rendered.include?("Themes")).to eql(false)
    expect(rendered.include?("Notifications")).to eql(false)
    # TODO: enable this one once that code is merged in
    # expect(rendered.include?("Api Clients")).to eql(false)
  end

  it "renders correctly for a super admin" do
    sign_in create(:user, :super_admin)
    render
    expect(rendered.include?("My Dashboard")).to eql(true)
    expect(rendered.include?("Create plan")).to eql(true)
    expect(rendered.include?("Admin Features")).to eql(true)
    expect(rendered.include?("Organisations")).to eql(true)
    expect(rendered.include?("Organisation details")).to eql(false)
    expect(rendered.include?("Users")).to eql(true)
    expect(rendered.include?("Plans")).to eql(true)
    expect(rendered.include?("Usage")).to eql(true)
    expect(rendered.include?("Templates")).to eql(true)
    expect(rendered.include?("Guidance")).to eql(true)
    expect(rendered.include?("Themes")).to eql(true)
    expect(rendered.include?("Notifications")).to eql(true)
    # TODO: enable this one once that code is merged in
    # expect(rendered.include?("Api Clients")).to eql(true)
  end

end
