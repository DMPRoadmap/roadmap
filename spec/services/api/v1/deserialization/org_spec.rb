# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Deserialization::Org do

  before(:each) do
    # Org requires a language, so make sure a default is available!
    create(:language, default_language: true) unless Language.default

    @name = Faker::Company.name
    @abbrev = Faker::Lorem.word.upcase
    @org = create(:org, name: @name, abbreviation: @abbrev)
    @scheme = create(:identifier_scheme)
    @identifier = create(:identifier, identifiable: @org,
                                      identifier_scheme: @scheme,
                                      value: SecureRandom.uuid)
    @org.reload
    @json = { name: @name, abbreviation: @abbrev }
  end

  describe "#deserialize!(json: {})" do
    before(:each) do
      described_class.stubs(:find_by_identifier).returns(nil)
      described_class.stubs(:find_by_name).returns(@org)
    end

    it "returns nil if json is not valid" do
      expect(described_class.deserialize!(json: nil)).to eql(nil)
    end
    it "calls find_by_identifier" do
      described_class.expects(:find_by_identifier).at_least(1)
      described_class.deserialize!(json: @json)
    end
    it "calls find_by_name if find_by_identifier finds none" do
      result = described_class.deserialize!(json: @json)
      expect(result).to eql(@org)
    end
    it "sets the language to the default" do
      default = Language.default || create(:language)
      result = described_class.deserialize!(json: @json)
      expect(result.language).to eql(default)
    end
    it "sets the abbreviation" do
      result = described_class.deserialize!(json: @json)
      expect(result.abbreviation).to eql(@abbrev)
    end
    it "returns nil if the Org is not valid" do
      Org.any_instance.stubs(:valid?).returns(false)
      expect(described_class.deserialize!(json: @json)).to eql(nil)
    end
    it "attaches the identifier to the Org" do
      id = SecureRandom.uuid
      scheme = create(:identifier_scheme, identifier_prefix: nil, name: "foo")
      json = @json.merge(
        { affiliation_id: { type: scheme.name, identifier: id } }
      )
      result = described_class.deserialize!(json: json)
      expect(result.identifiers.length).to eql(2)
      expect(result.identifiers.last.value).to eql(id)
    end
    it "is able to create a new Org" do
      described_class.stubs(:find_by_name)
                     .returns(build(:org, name: Faker::Company.name))
      result = described_class.deserialize!(json: @json)
      expect(result.new_record?).to eql(false)
      expect(result.abbreviation).to eql(@json[:abbreviation])
    end
  end

  context "private methods" do

    describe "#valid?(json:)" do
      it "returns false if json is not present" do
        expect(described_class.send(:valid?, json: nil)).to eql(false)
      end
      it "returns false if :name is not present" do
        json = { abbreviation: @abbrev }
        expect(described_class.send(:valid?, json: json)).to eql(false)
      end
      it "returns true" do
        expect(described_class.send(:valid?, json: @json)).to eql(true)
      end
    end

    describe "#find_by_identifier(json:)" do
      it "returns nil if json is not present" do
        expect(described_class.send(:find_by_identifier, json: nil)).to eql(nil)
      end
      it "returns nil if :affiliation_id and :funder_id are not present" do
        expect(described_class.send(:find_by_identifier, json: @json)).to eql(nil)
      end
      it "finds the Org by :affiliation_id" do
        json = @json.merge(
          { affiliation_id: { type: @scheme.name, identifier: @identifier.value } }
        )
        expect(described_class.send(:find_by_identifier, json: json)).to eql(@org)
      end
      it "finds the Org by :funder_id" do
        json = @json.merge(
          { funder_id: { type: @scheme.name, identifier: @identifier.value } }
        )
        expect(described_class.send(:find_by_identifier, json: json)).to eql(@org)
      end
      it "returns nil if no Org was found" do
        json = @json.merge(
          { affiliation_id: { type: @scheme.name, identifier: SecureRandom.uuid } }
        )
        expect(described_class.send(:find_by_identifier, json: json)).to eql(nil)
      end
    end

    describe "#find_by_name(json:)" do
      it "returns nil if json is not present" do
        expect(described_class.send(:find_by_name, json: nil)).to eql(nil)
      end
      it "returns nil if :name is not present" do
        json = { abbreviation: @abbrev }
        expect(described_class.send(:find_by_name, json: json)).to eql(nil)
      end
      it "finds the matching Org by name" do
        expect(described_class.send(:find_by_name, json: @json)).to eql(@org)
      end
      it "finds the Org from the OrgSelection::SearchService" do
        json = { name: Faker::Company.unique.name }
        array = [{ name: @org.name, weight: 0 }]
        OrgSelection::SearchService.stubs(:search_externally).returns(array)
        OrgSelection::HashToOrgService.stubs(:to_org).returns(@org)
        expect(described_class.send(:find_by_name, json: json)).to eql(@org)
      end
      it "initializes the Org if there were no viable matches" do
        json = { name: Faker::Company.unique.name }
        OrgSelection::SearchService.stubs(:search_externally).returns([])
        org = build(:org, name: json[:name])
        OrgSelection::HashToOrgService.stubs(:to_org).returns(org)
        expect(described_class.send(:find_by_name, json: json)).to eql(org)
      end
    end

    describe "#attach_identifier!(org:, json:)" do
      it "returns the Org as-is if json is not present" do
        result = described_class.send(:attach_identifier!, org: @org, json: nil)
        expect(result.identifiers).to eql(@org.identifiers)
      end
      it "returns the Org as-is if the json has no identifier" do
        result = described_class.send(:attach_identifier!, org: @org, json: @json)
        expect(result.identifiers).to eql(@org.identifiers)
      end
      it "returns the Org as-is if the Org already has the :affiliation_id" do
        json = @json.merge(
          { affiliation_id: { type: @scheme.name, identifier: @identifier.value } }
        )
        result = described_class.send(:attach_identifier!, org: @org, json: json)
        expect(result.identifiers).to eql(@org.identifiers)
      end
      it "returns the Org as-is if the Org already has the :funder_id" do
        json = @json.merge(
          { funder_id: { type: @scheme.name, identifier: @identifier.value } }
        )
        result = described_class.send(:attach_identifier!, org: @org, json: json)
        expect(result.identifiers).to eql(@org.identifiers)
      end
      it "adds the :affiliation_id to the Org" do
        scheme = create(:identifier_scheme)
        json = @json.merge(
          { affiliation_id: { type: scheme.name, identifier: @identifier.value } }
        )
        result = described_class.send(:attach_identifier!, org: @org, json: json)
        expect(result.identifiers.length > @org.identifiers.length).not_to eql(true)
        expect(result.identifiers.last.identifier_scheme).to eql(scheme)
        id = result.identifiers.last.value
        expect(id.end_with?(@identifier.value)).to eql(true)
      end
      it "adds the :funder_id to the Org" do
        scheme = create(:identifier_scheme)
        json = @json.merge(
          { funder_id: { type: scheme.name, identifier: @identifier.value } }
        )
        result = described_class.send(:attach_identifier!, org: @org, json: json)
        expect(result.identifiers.length > @org.identifiers.length).not_to eql(true)
        expect(result.identifiers.last.identifier_scheme).to eql(scheme)
        id = result.identifiers.last.value
        expect(id.end_with?(@identifier.value)).to eql(true)
      end
    end

  end

end
