# frozen_string_literal: true

require "rails_helper"

describe "layouts/_analytics.html.erb" do

  before(:each) do
    controller.prepend_view_path "app/views/branded"
    org = create(:org, name: ApplicationService.application_name,
                       abbreviation: ApplicationService.application_name)
    create(:tracker, org: org, code: "UA-123456789-0")
    org.reload
    @gkey = org.tracker.code
    @expected_usersnap = "//api.usersnap.com/load/#{SecureRandom.uuid}.js"
    Rails.env.stubs(:stage?).returns(true)
    Rails.env.stubs(:production?).returns(false)
    Rails.configuration.x.google_analytics.tracker_root = @gkey
    Rails.application.credentials.stubs(:usersnap).returns({ key: @expected_usersnap })
    Rails.configuration.x.google_analytics.tracker_root = ApplicationService.application_name
  end

  context "renders nothing" do
    it "when Rails.configuration.x.google_analytics.tracker_root is empty" do
      Rails.configuration.x.google_analytics.tracker_root = nil
      render
      expect(rendered.include?(@expected_usersnap)).to eql(true)
      expect(rendered.include?(@gkey)).to eql(false)
    end
    it "when :usersnap_key and :google_analytics_key are not present" do
      Rails.configuration.x.google_analytics.tracker_root = nil
      Rails.application.credentials.stubs(:usersnap).returns({ key: nil })
      render
      expect(rendered.include?(@expected_usersnap)).to eql(false)
      expect(rendered.include?(@gkey)).to eql(false)
    end
    it "when Rails.env.stage? and Rails.env.production? are false" do
      Rails.env.stubs(:stage?).returns(false)
      Rails.env.stubs(:production?).returns(false)
      render
      expect(rendered.include?(@expected_usersnap)).to eql(false)
      expect(rendered.include?(@gkey)).to eql(false)
    end
  end

  it "Rails.env.stage?" do
    Rails.env.stubs(:stage?).returns(true)
    Rails.env.stubs(:production?).returns(false)
    render
    expect(rendered.include?(@expected_usersnap)).to eql(true)
    expect(rendered.include?(@gkey)).to eql(true)
  end

  it "Rails.env.production?" do
    Rails.env.stubs(:stage?).returns(false)
    Rails.env.stubs(:production?).returns(true)
    render
    expect(rendered.include?(@expected_usersnap)).to eql(false)
    expect(rendered.include?(@gkey)).to eql(true)
  end

end
