# frozen_string_literal: true

require "rails_helper"

describe "layouts/_analytics.html.erb" do

  before(:each) do
    controller.prepend_view_path "app/views/branded"
    @keys = {
      usersnap_key: SecureRandom.uuid,
      google_analytics_key: SecureRandom.uuid
    }
    @expected_usersnap = "//api.usersnap.com/load/#{@keys[:usersnap_key]}.js"
    gkey = @keys[:google_analytics_key]
    @expected_google = "https://www.googletagmanager.com/gtag/js?id=#{gkey}"
  end

  context "renders nothing" do
    it "when Rails.configuration.branding[:keys] is empty" do
      Rails.configuration.branding[:keys] = []
      render
      expect(rendered.include?(@expected_usersnap)).to eql(false)
      expect(rendered.include?(@expected_google)).to eql(false)
    end
    it "when :usersnap_key and :google_analytics_key are not present" do
      Rails.configuration.branding[:keys] = []
      render
      expect(rendered.include?(@expected_usersnap)).to eql(false)
      expect(rendered.include?(@expected_google)).to eql(false)
    end
    it "when Rails.env.stage? and Rails.env.production? are false" do
      Rails.configuration.branding[:keys] = @keys
      Rails.env.stubs(:stage?).returns(false)
      Rails.env.stubs(:production?).returns(false)
      render
      expect(rendered.include?(@expected_usersnap)).to eql(false)
      expect(rendered.include?(@expected_google)).to eql(false)
    end
  end

  it "Rails.env.stage?" do
    Rails.configuration.branding[:keys] = @keys
    Rails.env.stubs(:stage?).returns(true)
    render
    expect(rendered.include?(@expected_usersnap)).to eql(true)
    expect(rendered.include?(@expected_google)).to eql(true)
  end

  it "Rails.env.production?" do
    Rails.configuration.branding[:keys] = @keys
    Rails.env.stubs(:production?).returns(true)
    render
    expect(rendered.include?(@expected_usersnap)).to eql(false)
    expect(rendered.include?(@expected_google)).to eql(true)
  end

end
