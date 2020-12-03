# frozen_string_literal: true

require "rails_helper"

describe "layouts/mobile/_fixed_menu.html.erb" do

  before(:each) do
    controller.prepend_view_path "app/views/branded"
  end

  context "user not logged in when Shibboleth is enabled" do
    it "renders our version of the page" do
      Rails.configuration.x.shibboleth.enabled = true
      render
      expect(rendered.include?("DMPTool_logo_blue_shades_v1b3b")).to eql(true)
      expect(rendered.include?("Sign in")).to eql(true)
      expect(rendered.include?("Sign in through an affiliated institution")).to eql(true)
      expect(rendered.include?("Sign in with your email address")).to eql(true)
      expect(rendered.include?("Create account with email address")).to eql(true)
      expect(response).to render_template(partial: "layouts/_learn_menu")
      expect(response).not_to render_template(partial: "layouts/_app_menu_links")
      expect(response).not_to render_template(partial: "layouts/_org_links")
      expect(response).not_to render_template(partial: "layouts/_profile_menu")
      expect(response).to render_template(partial: "layouts/_language_menu")
    end
  end

  context "user not logged in when Shibboleth is NOT enabled" do
    it "renders our version of the page" do
      Rails.configuration.x.shibboleth.enabled = false
      render
      expect(rendered.include?("DMPTool_logo_blue_shades_v1b3b")).to eql(true)
      expect(rendered.include?("Sign in")).to eql(true)
      expect(rendered.include?("Sign in through an affiliated institution")).to eql(false)
      expect(rendered.include?("Sign in with your email address")).to eql(true)
      expect(rendered.include?("Create account with email address")).to eql(true)
      expect(response).to render_template(partial: "layouts/_learn_menu")
      expect(response).not_to render_template(partial: "layouts/_app_menu_links")
      expect(response).not_to render_template(partial: "layouts/_org_links")
      expect(response).not_to render_template(partial: "layouts/_profile_menu")
      expect(response).to render_template(partial: "layouts/_language_menu")
    end
  end

  context "user is logged in" do
    it "renders our version of the page" do
      user = create(:user, org: create(:org))
      sign_in user
      render
      expect(rendered.include?("<p><strong>#{user.org.name}</strong></p>")).to eql(true)
      expect(rendered.include?(user.org.abbreviation)).to eql(true)
      expect(rendered.include?("Sign in")).to eql(false)
      expect(rendered.include?("Sign in through an affiliated institution")).to eql(false)
      expect(rendered.include?("Sign in with your email address")).to eql(false)
      expect(rendered.include?("Create account with email address")).to eql(false)
      expect(response).to render_template(partial: "layouts/_learn_menu")
      expect(response).to render_template(partial: "layouts/_app_menu_links")
      expect(response).to render_template(partial: "layouts/_org_links")
      expect(response).to render_template(partial: "layouts/_profile_menu")
      expect(response).to render_template(partial: "layouts/_language_menu")
    end
  end

end
