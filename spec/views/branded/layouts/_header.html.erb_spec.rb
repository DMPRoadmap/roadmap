# frozen_string_literal: true

require "rails_helper"

describe "layouts/_header.html.erb" do

  before(:each) do
    controller.prepend_view_path "app/views/branded"
  end

  it "renders correctly when user is NOT logged in" do
    render
    expect(response).to render_template(partial: "layouts/_fixed_menu")
    expect(response).to render_template(partial: "layouts/mobile/_fixed_menu")
    expect(response).to render_template(partial: "layouts/_branding")
    expect(response).not_to render_template(partial: "layouts/_app_menu")
  end

  it "renders correctly when user is logged in" do
    sign_in create(:user, org: create(:org))
    render
    expect(response).to render_template(partial: "layouts/_fixed_menu")
    expect(response).to render_template(partial: "layouts/mobile/_fixed_menu")
    expect(response).to render_template(partial: "layouts/_branding")
    expect(response).to render_template(partial: "layouts/_app_menu")
  end

end
