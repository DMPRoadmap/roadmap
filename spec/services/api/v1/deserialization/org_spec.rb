# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Deserialization::Org do
  before(:each) do
    # Org requires a language, so make sure a default is available!
    create(:language, abbreviation: 'v1-org', default_language: true) unless Language.default

    @name = Faker::Company.unique.name
    @abbrev = Faker::Lorem.word.upcase
    @org = create(:org, name: @name, abbreviation: @abbrev)
    @scheme = create(:identifier_scheme)
    @identifier = create(:identifier, identifiable: @org,
                                      identifier_scheme: @scheme,
                                      value: SecureRandom.uuid)
    @org.reload
    @json = { name: @name, abbreviation: @abbrev }
  end

  describe '#deserialize(json: {})' do
    before(:each) do
      described_class.stubs(:find_by_name).returns(@org)
      Api::V1::DeserializationService.stubs(:object_from_identifier).returns(nil)
    end

    it 'returns nil if json is not valid' do
      expect(described_class.deserialize(json: nil)).to eql(nil)
    end
    it 'returns the Org if found by :object_from_identifier' do
      Api::V1::DeserializationService.stubs(:object_from_identifier).returns(@org)
      result = described_class.deserialize(json: @json)
      expect(result).to eql(@org)
    end
    it 'calls find_by_name if :object_from_identifier finds none' do
      result = described_class.deserialize(json: @json)
      expect(result).to eql(@org)
    end
    it 'sets the language to the default' do
      default = Language.default || create(:language, abbreviation: 'v1-org-dflt')
      result = described_class.deserialize(json: @json)
      expect(result.language).to eql(default)
    end
    it 'sets the abbreviation' do
      result = described_class.deserialize(json: @json)
      expect(result.abbreviation).to eql(@abbrev)
    end
    it 'returns nil if the Org is not valid' do
      Org.any_instance.stubs(:valid?).returns(false)
      expect(described_class.deserialize(json: @json)).to eql(nil)
    end
    it 'attaches the identifier to the Org' do
      id = SecureRandom.uuid
      scheme = create(:identifier_scheme, identifier_prefix: nil, name: 'foo')
      json = @json.merge(
        { affiliation_id: { type: scheme.name, identifier: id } }
      )
      result = described_class.deserialize(json: json)
      expect(result.identifiers.length).to eql(2)
      expect(result.identifiers.last.value).to eql(id)
    end
    it 'is able to initialize a new Org' do
      described_class.stubs(:find_by_name)
                     .returns(build(:org, name: Faker::Company.unique.name))
      result = described_class.deserialize(json: @json)
      expect(result.new_record?).to eql(true)
      expect(result.abbreviation).to eql(@json[:abbreviation])
    end
  end

  context 'private methods' do
    describe '#find_by_name(json:)' do
      it 'returns nil if json is not present' do
        expect(described_class.send(:find_by_name, json: nil)).to eql(nil)
      end
      it 'returns nil if :name is not present' do
        json = { abbreviation: @abbrev }
        expect(described_class.send(:find_by_name, json: json)).to eql(nil)
      end
      it 'finds the matching Org by name' do
        expect(described_class.send(:find_by_name, json: @json)).to eql(@org)
      end
      it 'finds the Org from the OrgSelection::SearchService' do
        json = { name: Faker::Company.unique.name }
        array = [{ name: @org.name, weight: 0 }]
        OrgSelection::SearchService.stubs(:search_externally).returns(array)
        OrgSelection::HashToOrgService.stubs(:to_org).returns(@org)
        expect(described_class.send(:find_by_name, json: json)).to eql(@org)
      end
      it 'initializes the Org if there were no viable matches' do
        json = { name: Faker::Company.unique.name }
        OrgSelection::SearchService.stubs(:search_externally).returns([])
        org = build(:org, name: json[:name])
        OrgSelection::HashToOrgService.stubs(:to_org).returns(org)
        expect(described_class.send(:find_by_name, json: json)).to eql(org)
      end
    end
  end
end
