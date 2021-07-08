# frozen_string_literal: true

require "rails_helper"

describe "layouts/_analytics.html.erb" do

  before(:each) do
    controller.prepend_view_path "app/views/branded"
  end

  it "renders nothing if not the Stage or Production environments" do
    Rails.env.stubs(:stage?).returns(false)
    Rails.env.stubs(:production?).returns(false)
    render
    expect(rendered).to eql("\n")
  end

  describe "UserSnap" do
    it "does not display if we are in Production" do
      Rails.env.stubs(:stage?).returns(false)
      Rails.env.stubs(:production?).returns(true)
      render
      expect(rendered.include?("window.onUsersnapCXLoad")).to eql(false)
    end
    it "does not display if no UserSnap key is defined" do
      Rails.env.stubs(:stage?).returns(true)
      Rails.env.stubs(:production?).returns(false)
      Rails.configuration.x.dmproadmap.usersnap_key = nil
      render
      expect(rendered.include?("window.onUsersnapCXLoad")).to eql(false)
    end
    it "displays if it is Stage and the UserSnap key is defined" do
      Rails.env.stubs(:stage?).returns(true)
      Rails.env.stubs(:production?).returns(false)
      Rails.configuration.x.dmproadmap.usersnap_key = SecureRandom.uuid
      render
      expect(rendered.include?("window.onUsersnapCXLoad")).to eql(true)
    end
  end

  context "Google Analytics" do
    describe "Stage environment" do
      before(:each) do
        Rails.env.stubs(:stage?).returns(true)
        Rails.env.stubs(:production?).returns(false)
        default_org = create(:org)
        create(:tracker, org: default_org)
        @default_org = default_org.reload
      end

      it "does not display if no Tracker Root is NOT defined" do
        Rails.configuration.x.dmproadmap.google_analytics_tracker_root = nil
        render
        expect(rendered.include?("GoogleAnalyticsObject")).to eql(false)
        expect(rendered.include?("clientTracker")).to eql(false)
      end
      it "displays if the Tracker Root key is defined" do
        Rails.configuration.x.dmproadmap.google_analytics_tracker_root = @default_org.abbreviation
        render
        expect(rendered.include?("GoogleAnalyticsObject")).to eql(true)
        expect(rendered.include?("clientTracker")).to eql(false)
      end
      it "displays the Client Org key if it is defined" do
        org = create(:org)
        create(:tracker, org: org)
        user = create(:user, org: org.reload)
        Rails.configuration.x.dmproadmap.google_analytics_tracker_root = @default_org.abbreviation
        sign_in(user)
        render
        expect(rendered.include?("GoogleAnalyticsObject")).to eql(true)
        expect(rendered.include?("clientTracker")).to eql(true)
      end
    end

    describe "Production environment" do
      before(:each) do
        Rails.env.stubs(:stage?).returns(false)
        Rails.env.stubs(:production?).returns(true)
        default_org = create(:org)
        create(:tracker, org: default_org)
        @default_org = default_org.reload
      end

      it "does not display if no Tracker Root is NOT defined" do
        Rails.configuration.x.dmproadmap.google_analytics_tracker_root = nil
        render
        expect(rendered.include?("GoogleAnalyticsObject")).to eql(false)
        expect(rendered.include?("clientTracker")).to eql(false)
      end
      it "displays if the Tracker Root key is defined" do
        Rails.configuration.x.dmproadmap.google_analytics_tracker_root = @default_org.abbreviation
        render
        expect(rendered.include?("GoogleAnalyticsObject")).to eql(true)
        expect(rendered.include?("clientTracker")).to eql(false)
      end
      it "displays the Client Org key if it is defined" do
        org = create(:org)
        create(:tracker, org: org)
        user = create(:user, org: org.reload)
        Rails.configuration.x.dmproadmap.google_analytics_tracker_root = @default_org.abbreviation
        sign_in(user)
        render
        expect(rendered.include?("GoogleAnalyticsObject")).to eql(true)
        expect(rendered.include?("clientTracker")).to eql(true)
      end
    end
  end

end
