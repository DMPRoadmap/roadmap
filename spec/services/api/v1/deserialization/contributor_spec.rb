# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Deserialization::Contributor do
  before(:each) do
    # Org requires a language, so make sure a default is available!
    create(:language, abbreviation: 'v1-contrib', default_language: true) unless Language.default
    @org = create(:org)
    @plan = build(:plan, template: create(:template), org: @org)

    @name = Faker::Movies::StarWars.character
    @email = Faker::Internet.email

    @contributor = build(:contributor, org: @org, plan: @plan,
                                       name: @name, email: @email)
    @role = "#{Contributor::ONTOLOGY_BASE_URL}/#{@contributor.selected_roles.first}"

    @scheme = create(:identifier_scheme)
    @identifier = build(:identifier, identifiable: @contributor,
                                     identifier_scheme: @scheme,
                                     value: SecureRandom.uuid)
    @contributor.identifiers << @identifier
    @json = {
      name: @name,
      mbox: @email,
      role: [@role],
      affiliation: { name: @org.name }
    }
  end

  describe ':deserialize(json: {})' do
    it 'returns nil if json is not valid' do
      Api::V1::JsonValidationService.stubs(:contributor_valid?).returns(false)
      expect(described_class.deserialize(json: nil)).to eql(nil)
    end
    it 'attaches the Org to the Contributor' do
      result = described_class.send(:deserialize, json: @json)
      expect(result.org).to eql(@org)
    end
    it 'attaches the Identifier to the Contributor' do
      @identifier.destroy
      @json[:contributor_id] = { type: @scheme.name, identifier: SecureRandom.uuid }
      result = described_class.send(:deserialize, json: @json)
      expected = "#{@scheme.identifier_prefix}#{@json[:contributor_id][:identifier]}"
      expect(result.identifiers.length).to eql(1)
      expect(result.identifiers.last.value).to eql(expected)
    end
    it 'assigns the contact role if this :is_contact is true' do
      @json[:contact_id] = { type: 'URL', identifier: Faker::Internet.url }
      result = described_class.send(:deserialize, json: @json, is_contact: true)
      expect(result.data_curation?).to eql(true)
    end
    it 'does not assign the contact role if this :is_contact is false' do
      @json[:contact_id] = { type: 'URL', identifier: Faker::Internet.url }
      result = described_class.send(:deserialize, json: @json)
      expect(result.data_curation?).to eql(false)
    end
    it 'assigns the contributor role' do
      role = @contributor.all_roles[1].to_s
      json = { name: Faker::TvShows::Simpsons.character, role: [role] }
      result = described_class.send(:deserialize, json: json)
      expect(result.send(:"#{role}?")).to eql(true)
    end
  end

  context 'private methods' do
    describe ':find_or_initialize(id_json:, json: {})' do
      it 'returns nil if json is not present' do
        result = described_class.send(:find_or_initialize, id_json: nil, json: nil)
        expect(result).to eql(nil)
      end
      it 'returns a cloned copy of the Contributor when found by identifier' do
        contributor = create(:contributor, plan: @plan)
        Api::V1::DeserializationService.expects(:object_from_identifier).returns(contributor)
        result = described_class.send(:find_or_initialize, id_json: nil, json: @json)
        expect(result).not_to eql(contributor)
        expect(result.new_record?).to eql(true)
        expect(result.plan).to eql(nil)
        expect(result.name).to eql(contributor.name)
        expect(result.email).to eql(contributor.email)
      end
      it 'returns a cloned copy of the Contributor when found by email' do
        contributor = create(:contributor, email: @json[:mbox], plan: @plan)
        Api::V1::DeserializationService.expects(:object_from_identifier).returns(nil)
        result = described_class.send(:find_or_initialize, id_json: nil, json: @json)
        expect(result).not_to eql(contributor)
        expect(result.new_record?).to eql(true)
        expect(result.plan).to eql(nil)
        expect(result.name).to eql(contributor.name)
        expect(result.email).to eql(contributor.email)
      end
      it 'initializes the Contributor if there were no viable matches' do
        json = {
          name: Faker::TvShows::Simpsons.character,
          mbox: Faker::Internet.unique.email
        }
        Api::V1::DeserializationService.expects(:object_from_identifier).returns(nil)
        result = described_class.send(:find_or_initialize, id_json: nil, json: json)
        expect(result.new_record?).to eql(true)
        expect(result.plan).to eql(nil)
        expect(result.name).to eql(json[:name])
        expect(result.email).to eql(json[:mbox])
      end
    end

    describe ':duplicate_contributor(contributor:)' do
      it 'returns nil if the contributor is not present' do
        expect(described_class.send(:duplicate_contributor, contributor: nil)).to eql(nil)
      end
      it 'duplicates the contributor' do
        result = described_class.send(:duplicate_contributor, contributor: @contributor)
        expect(result.new_record?).to eql(true)
      end
      it 'removes the plan association' do
        result = described_class.send(:duplicate_contributor, contributor: @contributor)
        expect(result.plan).to eql(nil)
      end
    end

    describe ':assign_contact_roles(contributor:)' do
      it 'returns :contributor as-is if it is not present' do
        result = described_class.send(:assign_contact_roles, contributor: nil)
        expect(result).to eql(nil)
      end
      it 'assigns the :data_curation role' do
        result = described_class.send(:assign_contact_roles, contributor: @contributor)
        expect(result.data_curation?).to eql(true)
      end
    end

    describe ':assign_roles(contributor:, json:)' do
      it 'returns :contributor as-is if it is not present' do
        result = described_class.send(:assign_roles, contributor: nil, json: @json)
        expect(result).to eql(nil)
      end
      it 'returns the :contributor as-is if json is not present' do
        result = described_class.send(:assign_roles, contributor: @contributor,
                                                     json: nil)
        expect(result).to eql(@contributor)
      end
      it 'returns the :contributor as-is if json[:role] is not present' do
        json = { name: @name }
        result = described_class.send(:assign_roles, contributor: @contributor,
                                                     json: json)
        expect(result).to eql(@contributor)
      end
      it 'ignores unknown/undefined roles' do
        @json[:role] << Faker::Lorem.word
        result = described_class.send(:assign_roles, contributor: @contributor,
                                                     json: @json)
        expect(result.selected_roles).to eql(@contributor.selected_roles)
      end
      it 'calls the translate_role' do
        Api::V1::DeserializationService.expects(:translate_role).at_least(1)
        described_class.send(:assign_roles, contributor: @contributor, json: @json)
      end
      it 'assigns the roles' do
        result = described_class.send(:assign_roles, contributor: @contributor,
                                                     json: @json)
        expect(result.selected_roles).to eql(@contributor.selected_roles)
      end
    end
  end
end
