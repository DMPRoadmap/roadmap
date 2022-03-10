# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::Deserialization::RelatedIdentifier do
  before(:each) do
    @plan = create(:plan)
    @json = {
      descriptor: RelatedIdentifier.relation_types.keys.sample,
      type: RelatedIdentifier.identifier_types.keys.sample,
      identifier: SecureRandom.uuid
    }
  end

  describe ':deserialize(plan:, json: {})' do
    it 'returns nil if :plan is not present' do
      expect(described_class.deserialize(plan: nil, json: @json)).to eql(nil)
    end
    it 'returns nil if json is not valid' do
      Api::V2::JsonValidationService.expects(:related_identifier_valid?).returns(false)
      expect(described_class.deserialize(plan: @plan, json: @json)).to eql(nil)
    end
    it 'initializes a new RelatedIdentifier when the plan does not have one' do
      rslt = described_class.deserialize(plan: @plan, json: @json)
      expect(rslt.new_record?).to eql(true)
      expect(rslt.relation_type).to eql(@json[:descriptor])
      expect(rslt.identifier_type).to eql(@json[:type])
      expect(rslt.value).to eql(@json[:identifier])
    end
    it 'properly converts :descriptor value `references` to `does_reference`' do
      rslt = described_class.deserialize(plan: @plan, json: @json)
      expect(rslt.new_record?).to eql(true)
      expect(rslt.relation_type).to eql(@json[:descriptor])
      expect(rslt.identifier_type).to eql(@json[:type])
      expect(rslt.value).to eql(@json[:identifier])
    end
    it 'does not duplicate an existing RelatedIdentifier' do
      r_id = create(:related_identifier, value: @json[:identifier], identifiable: @plan)
      rslt = described_class.deserialize(plan: @plan, json: @json)
      expect(rslt.new_record?).to eql(false)
      expect(rslt.relation_type).to eql(@json[:descriptor])
      expect(rslt.identifier_type).to eql(@json[:type])
      expect(rslt.value).to eql(r_id.value)
    end
  end
end
