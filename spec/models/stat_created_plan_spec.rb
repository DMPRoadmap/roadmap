require 'rails_helper'

RSpec.describe StatCreatedPlan, type: :model do
  describe '.to_csv' do
    context 'when no instances' do
      it 'returns empty' do
        csv = described_class.to_csv([])

        expect(csv).to be_empty
      end
    end
    context 'when instances' do
      let(:org) { FactoryBot.create(:org) }
      it 'returns instances in a comma-separated row' do
        may = FactoryBot.create(:stat_created_plan, date: Date.new(2018, 05, 31), org: org, count: 20)
        june = FactoryBot.create(:stat_created_plan, date: Date.new(2018, 06, 30), org: org, count: 10)
        data = [may, june]

        csv = described_class.to_csv(data)

        expected_csv = <<~HERE
          Date,Count
          2018-05-31,20
          2018-06-30,10
        HERE
        expect(csv).to eq(expected_csv)
      end
    end
  end
end
