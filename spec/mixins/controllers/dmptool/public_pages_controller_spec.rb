# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dmptool::PublicPagesController, type: :request do

  before(:each) do
    @controller = ::PublicPagesController.new
  end

  it "PublicPagesController includes our customizations" do
    expect(@controller.respond_to?(:orgs)).to eql(true)
  end

  describe "#orgs" do
    # Rspec request tests are expensive so only execute the GET once and then
    # do all the checks
    it "should be accessible when not logged in" do
      funder = create(:org, :funder, name: Faker::Name.unique.name)
      inst = create(:org, :institution, name: Faker::Name.unique.name)
      org = create(:org, :organisation, name: Faker::Name.unique.name)
      ri = create(:org, :research_institute, name: Faker::Name.unique.name)
      prj = create(:org, :project, name: Faker::Name.unique.name)
      sch = create(:org, :school, name: Faker::Name.unique.name)

      get public_orgs_path
      expect(response).to have_http_status(:success), "should have received a 200"
      expect(assigns(:orgs).present?).to eql(true), "should have assigned :orgs"
      expect(assigns(:orgs).include?(funder)).to eql(false), "should not have funders"
      expect(assigns(:orgs).include?(inst)).to eql(true), "should have institutions"
      expect(assigns(:orgs).include?(org)).to eql(true), "should have organisations"
      expect(assigns(:orgs).include?(ri)).to eql(true), "should have research institutes"
      expect(assigns(:orgs).include?(prj)).to eql(true), "should have projects"
      expect(assigns(:orgs).include?(sch)).to eql(true), "should have schools"
      expect(response.body.include?("<h1>Participating Institutions")).to eql(true)
    end
  end

  describe "#get_started" do
    it "should be accessible when not logged in" do
      get get_started_path
      expect(response).to have_http_status(:success)
      expect(response.body.include?("<h2>Sign in options")).to eql(true)
    end

  end

  # rubocop:disable Metrics/LineLength
  describe "#file_name" do
    it "replaces spaces, periods, commas, and colons with underscores" do
      expect(@controller.send(:file_name, "A title with spaces")).to eql("A_title_with_spaces")
      expect(@controller.send(:file_name, "A title with, comma")).to eql("A_title_with_comma")
      expect(@controller.send(:file_name, "A title with. period")).to eql("A_title_with_period")
      expect(@controller.send(:file_name, "A title with: colon")).to eql("A_title_with_colon")
      expect(@controller.send(:file_name, "A title with; semicolon")).to eql("A_title_with_semicolon")
    end

    it "removes newlines and carriage returns" do
      expect(@controller.send(:file_name, "A title with\nnewline")).to eql("A_title_with_newline")
      expect(@controller.send(:file_name, "A title with\rcarriage return")).to eql("A_title_with_carriage_return")
      expect(@controller.send(:file_name, "A title with\r\nboth")).to eql("A_title_with__both")
      expect(@controller.send(:file_name, "A title with
newline")).to eql("A_title_with_newline")
    end

    it "only uses the first 30 characters" do
      expect(@controller.send(:file_name, "0123456789012345678901234567890B")).to eql("0123456789012345678901234567890")
    end
  end
  # rubocop:enable Metrics/LineLength

end
