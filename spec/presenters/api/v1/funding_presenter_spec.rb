# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::FundingPresenter do
  describe '#status(plan:)' do
    it 'returns `planned` if the plan is nil' do
      expect(described_class.status(plan: nil)).to eql('planned')
    end
    it 'returns `planned` if the :funding_status is nil' do
      plan = build(:plan, funding_status: nil)
      expect(described_class.status(plan: plan)).to eql('planned')
    end
    it "returns `granted` if the :funding_status is 'funded'" do
      plan = build(:plan, funding_status: 'funded')
      expect(described_class.status(plan: plan)).to eql('granted')
    end
    it "returns `rejected` if the :funding_status is 'denied'" do
      plan = build(:plan, funding_status: 'denied')
      expect(described_class.status(plan: plan)).to eql('rejected')
    end
    it "returns `planned` if the :funding_status is 'planned'" do
      plan = build(:plan, funding_status: 'planned')
      expect(described_class.status(plan: plan)).to eql('planned')
    end
  end
end
