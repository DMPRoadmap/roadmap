# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrgSelection::OrgToHashService do

  before(:each) do
    @name = Faker::Lorem.word
    @scheme = build(:identifier_scheme)
    @id = build(:identifier, identifier_scheme: @scheme)
    @org = build(:org, name: "#{@name} (ABC)", identifiers: [@id])
  end

  describe "#to_hash(org:)" do
    before(:each) do
      @rslt = described_class.to_hash(org: @org)
    end

    it "returns an empty hash if the Org is nil" do
      expect(described_class.to_hash(org: nil)).to eql({})
    end
    it "places the Org.id into the :id parameter" do
      expect(@rslt[:id]).to eql(@org.id)
    end
    it "places the Org.name into the :name parameter" do
      expect(@rslt[:name]).to eql(@org.name)
    end
    it "places the Org.name (without an alias) into the :sort_name parameter" do
      expect(@rslt[:sort_name]).to eql(@name)
    end
    it "places identifiers into the correct `[scheme.name]: [value]` format" do
      expect(@rslt[:"#{@scheme.name}"]).to eql(@id.value)
    end
  end

end
