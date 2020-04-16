# frozen_string_literal: true

require "rails_helper"

describe "layouts/_profile_menu.html.erb" do

  before(:each) do
    controller.prepend_view_path "app/views/branded"
  end

  it "renders nothing when user is NOT logged in" do
    render
    expect(rendered).to eql("")
  end

  it "renders correctly when user is logged in" do
    user = create(:user)
    sign_in user
    render
    expect(rendered.include?(user.name(false))).to eql(true)
    expect(rendered.include?("Edit profile")).to eql(true)
    expect(rendered.include?("Logout")).to eql(true)
  end

end
