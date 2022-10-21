# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::Deserialization::Org do
  include Helpers::IdentifierHelper

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

  describe '#deserialize(json: {})' do
    before(:each) do
      described_class.stubs(:find_by_name).returns(@org)
      Api::V2::DeserializationService.stubs(:object_from_identifier).returns(nil)
    end

    it 'returns nil if json is not valid' do
      expect(described_class.deserialize(json: nil)).to eql(nil)
    end
    it 'returns the Org if found by :object_from_identifier' do
      Api::V2::DeserializationService.stubs(:object_from_identifier).returns(@org)
      result = described_class.deserialize(json: @json)
      expect(result).to eql(@org)
    end
    it 'calls find_by_name if :object_from_identifier finds none' do
      result = described_class.deserialize(json: @json)
      expect(result).to eql(@org)
    end
    it 'sets the language to the default' do
      default = Language.default || create(:language)
      result = described_class.deserialize(json: @json)
      expect(result.language).to eql(default)
    end
    it 'sets the abbreviation' do
      result = described_class.deserialize(json: @json)
      expect(result.abbreviation).to eql(@abbrev)
    end
    it 'is able to initialize a new Org' do
      @identifier.destroy
      described_class.expects(:find_by_name).returns(build(:org, name: Faker::Company.name))
      result = described_class.deserialize(json: @json)
      expect(result.new_record?).to eql(true)
      expect(result.abbreviation).to eql(@json[:abbreviation])
    end
  end

  context 'private methods' do
    describe ':find_by_name(json: {})' do
      it 'returns nil unless :json is present' do
        expect(described_class.send(:find_by_name, json: nil)).to eql(nil)
      end
      it 'returns nil unless json[:name] is present' do
        expect(described_class.send(:find_by_name, json: { title: 'foo' })).to eql(nil)
      end
      it 'finds the matching Org by name' do
        org = create(:org)
        expect(described_class.send(:find_by_name, json: { name: org.name })).to eql(org)
      end
      it 'does not attempt to find the RegistryOrg by name if the :restrict_orgs is true' do
        Rails.configuration.x.application.restrict_orgs = true
        registry_org = create(:registry_org)
        expect(described_class.send(:find_by_name, json: { name: registry_org.name })).to eql(nil)
      end
      it 'finds the matching RegistryOrg by name' do
        Rails.configuration.x.application.restrict_orgs = false
        registry_org = create(:registry_org)
        result = described_class.send(:find_by_name, json: { name: registry_org.name })
        expect(result.name).to eql(registry_org.name)
      end
      it 'returns nil if no Org or RegistryOrg could be found' do
        Rails.configuration.x.application.restrict_orgs = false
        name = Faker::Company.name
        create(:org, name: name)
        create(:registry_org, name: name)
        expect(described_class.send(:find_by_name, json: { name: 'foo-bar' })).to eql(nil)
      end
    end

    describe ':org_from_registry_org!(registry_org:)' do
      before(:each) do
        @registry_org = create(:registry_org)
        ror_scheme
        fundref_scheme
      end

      it 'returns nil unless :registry_org is a RegistryOrg' do
        expect(described_class.send(:org_from_registry_org!, registry_org: build(:org))).to eql(nil)
      end
      it 'returns the :registry_org associated Org if present' do
        org = create(:org)
        @registry_org.org = org
        @registry_org.expects(:to_org).never
        expect(described_class.send(:org_from_registry_org!, registry_org: @registry_org)).to eql(org)
      end
      it 'creates and returns a new Org record if the :registry_org does not have one assocciated' do
        result = described_class.send(:org_from_registry_org!, registry_org: @registry_org)
        expect(Org.all.last).to eql(result)
        expect(@registry_org.reload.org_id).to eql(result.id)
        ror = result.identifier_for_scheme(scheme: 'ror')
        fundref = result.identifier_for_scheme(scheme: 'fundref')
        expect(ror&.value).to eql(@registry_org.ror_id)
        expect(fundref&.value).to eql(@registry_org.fundref_id)
      end
    end
  end
end
