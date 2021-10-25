# frozen_string_literal: true

require "rails_helper"

describe "api/v1/plans/_funding.json.jbuilder" do

  before(:each) do
    @funder = create(:org, :funder)
    create(:identifier, identifiable: @funder,
                        identifier_scheme: create(:identifier_scheme, name: "fundref"))
    @funder.reload
    @plan = create(:plan, funder: @funder, org: create(:org), identifier: SecureRandom.uuid)
    create(:identifier, identifiable: @plan.org,
                        identifier_scheme: create(:identifier_scheme, name: "ror"))
    @grant = create(:identifier, identifiable: @plan)
    @plan.update(grant_id: @grant.id)
    @plan.reload

    render partial: "api/v1/plans/funding", locals: { plan: @plan }
    @json = JSON.parse(rendered).with_indifferent_access
  end

  describe "includes all of the funding attributes" do
    it "includes :name" do
      expect(@json[:name]).to eql(@funder.name)
    end
    it "includes :funding_status" do
      expected = Api::V1::FundingPresenter.status(plan: @plan)
      expect(@json[:funding_status]).to eql(expected)
    end
    it "includes :funder_ids" do
      id = @funder.identifiers.first
      expect(@json[:funder_id][:type]).to eql(id.identifier_format)
      expect(@json[:funder_id][:identifier]).to eql(id.value)
    end
    it "includes :dmproadmap_funding_opportunity_identifier" do
      identifier = @plan.identifier
      expect(@json[:dmproadmap_funding_opportunity_id][:type]).to eql("other")
      expect(@json[:dmproadmap_funding_opportunity_id][:identifier]).to eql(identifier)
    end
    it "includes :grant_ids" do
      expect(@json[:grant_id][:type]).to eql(@grant.identifier_format)
      expect(@json[:grant_id][:identifier]).to eql(@grant.value)
    end
    it "includes :dmproadmap_funded_affiliations" do
      org = @plan.org
      expect(@json[:dmproadmap_funded_affiliations].any?).to eql(true)
      affil = @json[:dmproadmap_funded_affiliations].last
      expect(affil[:name]).to eql(org.name)
      expect(affil[:affiliation_id][:type]).to eql(org.identifiers.last.identifier_format)
      expect(affil[:affiliation_id][:identifier]).to eql(org.identifiers.last.value)
    end
  end

end
