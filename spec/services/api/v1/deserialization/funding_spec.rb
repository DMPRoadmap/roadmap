# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Deserialization::Funding do
  before(:each) do
    # Org requires a language, so make sure a default is available!
    create(:language, abbreviation: 'v1-fund', default_language: true) unless Language.default

    @funder = create(:org, :funder, name: Faker::Company.name)
    @plan = create(:plan)
    @grant = create(:identifier, identifier_scheme: nil, value: SecureRandom.uuid,
                                 identifiable: @plan)

    Api::V1::Deserialization::Org.stubs(:deserialize!).returns(@funder)
    Api::V1::Deserialization::Identifier.stubs(:deserialize!).returns(@grant)

    @json = {
      name: @funder.name,
      funding_status: %w[planned granted rejected].sample
    }
  end

  describe '#deserialize(plan:, json: {})' do
    it 'returns nil if plan is not present' do
      expect(described_class.deserialize(plan: nil, json: @json)).to eql(nil)
    end
    it 'returns the Plan as-is if json is not valid' do
      json = { funding_status: 'planned' }
      expect(described_class.deserialize(plan: @plan, json: json)).to eql(@plan)
    end
    it 'assigns the funder' do
      result = described_class.deserialize(plan: @plan, json: @json)
      expect(result.funder).to eql(@funder)
    end
    it 'assigns the grant' do
      json = @json.merge({ grant_id: { type: 'url', identifier: Faker::Lorem.word } })
      result = described_class.deserialize(plan: @plan, json: json)
      expect(result.grant.value).to eql(json[:grant_id][:identifier])
    end
    it 'returns the Plan' do
      expect(described_class.deserialize(plan: @plan, json: @json)).to eql(@plan)
    end
  end
end
