# frozen_string_literal: true

require "rails_helper"

describe "layouts/_header.html.erb" do

  before(:each) do
    controller.prepend_view_path "app/views/branded"
  end

  it "renders properly when user is not signed in" do
    render
    expect(rendered.include?("<header class=\"c-header\">")).to eql(true)
    expect(rendered.include?("class=\"c-logo-dmptool\"")).to eql(true)

    expect(rendered.include?("class=\"c-navtoggle\"")).to eql(true)
    expect(rendered.include?("class=\"c-headernav\"")).to eql(true)
    expect(rendered.include?("Home")).to eql(true)
    expect(rendered.include?("Funder Requirements")).to eql(true)
    expect(rendered.include?("Public DMPs")).to eql(true)
    expect(rendered.include?("Help")).to eql(true)

    expect(rendered.include?("class=\"c-user-profile\"")).to eql(false)
    expect(rendered.include?("class=\"c-user-profile__button\"")).to eql(false)
    expect(rendered.include?("class=\"c-user-profile__menu\"")).to eql(false)
    expect(rendered.include?("Edit profile")).to eql(false)
    expect(rendered.include?("3rd party applications")).to eql(false)
    expect(rendered.include?("Developer tools")).to eql(false)
    expect(rendered.include?("Logout")).to eql(false)

    expect(rendered.include?("class=\"c-language\"")).to eql(true)
    expect(rendered.include?("class=\"c-language__button\"")).to eql(true)
    expect(rendered.include?("class=\"c-language__menu\"")).to eql(true)
    expect(rendered.include?("en-GB")).to eql(true)
  end

  it "renders properly when user is signed in" do
    sign_in(create(:user))
    render
    expect(rendered.include?("<header class=\"c-header\">")).to eql(true)
    expect(rendered.include?("class=\"c-logo-dmptool\"")).to eql(true)

    expect(rendered.include?("class=\"c-navtoggle\"")).to eql(true)
    expect(rendered.include?("class=\"c-headernav\"")).to eql(true)
    expect(rendered.include?("Home")).to eql(true)
    expect(rendered.include?("Funder Requirements")).to eql(true)
    expect(rendered.include?("Public DMPs")).to eql(true)
    expect(rendered.include?("Help")).to eql(true)

    expect(rendered.include?("class=\"c-user-profile\"")).to eql(true)
    expect(rendered.include?("class=\"c-user-profile__button\"")).to eql(true)
    expect(rendered.include?("class=\"c-user-profile__menu\"")).to eql(true)
    expect(rendered.include?("Edit profile")).to eql(true)
    expect(rendered.include?("3rd party applications")).to eql(true)
    expect(rendered.include?("Developer tools")).to eql(true)
    expect(rendered.include?("Logout")).to eql(true)

    expect(rendered.include?("class=\"c-language\"")).to eql(true)
    expect(rendered.include?("class=\"c-language__button\"")).to eql(true)
    expect(rendered.include?("class=\"c-language__menu\"")).to eql(true)
    expect(rendered.include?("en-GB")).to eql(true)
  end

end
