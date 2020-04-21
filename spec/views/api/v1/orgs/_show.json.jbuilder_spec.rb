# frozen_string_literal: true

require "rails_helper"

describe "api/v1/orgs/_show.json.jbuilder" do

  before(:each) do
    scheme = create(:identifier_scheme, name: "ror")
    @org = create(:org)
    @ident = create(:identifier, value: Faker::Lorem.word, identifiable: @org,
                                 identifier_scheme: scheme)
    @org.reload
    render partial: "api/v1/orgs/show", locals: { org: @org }
    @json = JSON.parse(rendered).with_indifferent_access
  end

  describe "includes all of the org attributes" do
    it "includes :name" do
      expect(@json[:name]).to eql(@org.name)
    end
    it "includes :abbreviation" do
      expect(@json[:abbreviation]).to eql(@org.abbreviation)
    end
    it "includes :region" do
      expect(@json[:region]).to eql(@org.region.abbreviation)
    end
    it "includes :affiliation_id" do
      expect(@json[:affiliation_id][:type]).to eql(@ident.identifier_format)
      expect(@json[:affiliation_id][:identifier]).to eql(@ident.value)
    end
    it "uses the ROR over the FundRef :affiliation_id" do
      scheme = create(:identifier_scheme, name: "fundref")
      create(:identifier, value: Faker::Lorem.word, identifiable: @org,
                          identifier_scheme: scheme)
      @org.reload
      expect(@json[:affiliation_id][:type]).to eql(@ident.identifier_format)
      expect(@json[:affiliation_id][:identifier]).to eql(@ident.value)
    end
  end

end
