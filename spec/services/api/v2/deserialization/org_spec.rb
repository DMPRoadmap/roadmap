# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::Deserialization::Org do

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

  describe "#deserialize(json: {})" do
    before(:each) do
      described_class.stubs(:find_by_name).returns(@org)
      Api::V2::DeserializationService.stubs(:object_from_identifier).returns(nil)
    end

    it "returns nil if json is not valid" do
      expect(described_class.deserialize(json: nil)).to eql(nil)
    end
    it "returns the Org if found by :object_from_identifier" do
      Api::V2::DeserializationService.stubs(:object_from_identifier).returns(@org)
      result = described_class.deserialize(json: @json)
      expect(result).to eql(@org)
    end
    it "calls find_by_name if :object_from_identifier finds none" do
      result = described_class.deserialize(json: @json)
      expect(result).to eql(@org)
    end
    it "sets the language to the default" do
      default = Language.default || create(:language)
      result = described_class.deserialize(json: @json)
      expect(result.language).to eql(default)
    end
    it "sets the abbreviation" do
      result = described_class.deserialize(json: @json)
      expect(result.abbreviation).to eql(@abbrev)
    end
    it "is able to initialize a new Org" do
      Api::V1::DeserializationService.stubs(:name_to_org)
                                     .returns(build(:org, name: Faker::Company.name))
      result = described_class.deserialize(json: @json)
      expect(result.new_record?).to eql(true)
      expect(result.abbreviation).to eql(@json[:abbreviation])
    end
  end

end
