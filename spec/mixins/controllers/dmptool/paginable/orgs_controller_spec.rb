# frozen_string_literal: true

require "rails_helper"

RSpec.describe Controllers::Dmptool::Paginable::OrgsController, type: :request do

  it "OrgsController includes our customizations" do
    expect(Paginable::OrgsController.new.respond_to?(:public)).to eql(true)
  end

  describe "#public" do
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
    end
  end

end
