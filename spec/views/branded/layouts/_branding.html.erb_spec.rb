# frozen_string_literal: true

require "rails_helper"

describe "layouts/_branding.html.erb" do

  before(:each) do
    controller.prepend_view_path "app/views/branded"
  end

  it "renders correctly when user is NOT logged in" do
    render
    expect(rendered.include?("branding-name")).to eql(false)
    expect(response).to render_template(partial: "layouts/_logo")
    expect(response).not_to render_template(partial: "layouts/_org_links")
  end

  it "renders correctly when user is logged in" do
    sign_in create(:user, org: create(:org))
    render
    expect(rendered.include?("branding-name")).to eql(true)
    expect(response).to render_template(partial: "layouts/_logo")
    expect(response).to render_template(partial: "layouts/_org_links")
  end

end
