# frozen_string_literal: true

require "rails_helper"

describe "layouts/application.html.erb" do

  before(:each) do
    @app_name = ApplicationService.application_name
    Rails.configuration.x.application.name = @app_name
    controller.prepend_view_path "app/views/branded"
  end

  it "displays correctly when user is not logged in and Shib is NOT enabled" do
    Rails.configuration.x.shibboleth.use_filtered_discovery_service = false
    render
    expect(response).to render_template(partial: "layouts/_analytics")
    expect(rendered.include?("<title>#{@app_name}")).to eql(true)
    expect(rendered.include?("Skip to main content")).to eql(true)
    expect(rendered.include?("<div class=\"dmptool\">")).to eql(true)
    expect(response).to render_template(partial: "layouts/_header")
    expect(response).to render_template(partial: "layouts/_notifications")
    expect(rendered.include?("<div class=\"content\">")).to eql(true)
    expect(response).not_to render_template(partial: "shared/_shib_ds_form")
    expect(response).to render_template(partial: "shared/_signin_create_form")
    expect(response).to render_template(partial: "shared/_get_started")
    expect(rendered.include?("<footer class=blue>")).to eql(false)
    expect(response).to render_template(partial: "layouts/_footer")
    expect(response).to render_template(partial: "layouts/mobile/_footer")
    expect(response).to render_template(partial: "layouts/_constants")
  end

  it "displays correctly when user is not logged in and Shib is enabled" do
    Rails.configuration.x.shibboleth.use_filtered_discovery_service = true
    render
    expect(response).to render_template(partial: "layouts/_analytics")
    expect(rendered.include?("<title>#{@app_name}")).to eql(true)
    expect(rendered.include?("Skip to main content")).to eql(true)
    expect(rendered.include?("<div class=\"dmptool\">")).to eql(true)
    expect(response).to render_template(partial: "layouts/_header")
    expect(response).to render_template(partial: "layouts/_notifications")
    expect(rendered.include?("<div class=\"content\">")).to eql(true)
    expect(response).to render_template(partial: "shared/_shib_ds_form")
    expect(response).to render_template(partial: "shared/_signin_create_form")
    expect(response).to render_template(partial: "shared/_get_started")
    expect(rendered.include?("<footer class=blue>")).to eql(false)
    expect(response).to render_template(partial: "layouts/_footer")
    expect(response).to render_template(partial: "layouts/mobile/_footer")
    expect(response).to render_template(partial: "layouts/_constants")
  end

  it "displays correctly when user is logged in" do
    Rails.configuration.x.shibboleth.use_filtered_discovery_service = true
    sign_in create(:user)
    render
    expect(response).to render_template(partial: "layouts/_analytics")
    expect(rendered.include?("<title>#{@app_name}")).to eql(true)
    expect(rendered.include?("Skip to main content")).to eql(true)
    expect(rendered.include?("<div class=\"dmptool\">")).to eql(true)
    expect(response).to render_template(partial: "layouts/_header")
    expect(response).to render_template(partial: "layouts/_notifications")
    expect(rendered.include?("<div class=\"content\">")).to eql(true)
    expect(response).not_to render_template(partial: "shared/_shib_ds_form")
    expect(response).not_to render_template(partial: "shared/_signin_create_form")
    expect(response).not_to render_template(partial: "shared/_get_started")
    expect(rendered.include?("<footer class=blue>")).to eql(true)
    expect(response).to render_template(partial: "layouts/_footer")
    expect(response).to render_template(partial: "layouts/mobile/_footer")
    expect(response).to render_template(partial: "layouts/_constants")
  end

end
