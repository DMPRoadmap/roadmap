require 'rails_helper'

RSpec.describe StatJoinedUser, type: :model do
  before(:example) do
    @org = FactoryBot.create(:org)
  end

  describe '.monthly_range' do
    context 'when org is missing' do
      it 'raises ArgumentError' do
        expect do
          described_class.monthly_range
        end.to raise_error(ArgumentError)
      end
    end
    it 'returns matching instances' do
      start_date = Date.new(2018, 04, 30)
      end_date = Date.new(2018, 05, 31)
      june = FactoryBot.create(:stat_joined_user, date: Date.new(2018, 06, 30), org: @org)
      may = FactoryBot.create(:stat_joined_user, date: end_date, org: @org)
      april = FactoryBot.create(:stat_joined_user, date: start_date, org: @org)

      april_to_may = described_class.monthly_range(org: @org, start_date: start_date, end_date: end_date)

      expect(april_to_may).to include(april, may)
    end
  end

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
        may = FactoryBot.create(:stat_joined_user, date: Date.new(2018, 05, 31), org: org, count: 20)
        june = FactoryBot.create(:stat_joined_user, date: Date.new(2018, 06, 30), org: org, count: 10)
        data = [may, june]

        csv = described_class.to_csv(data)

        expected_csv = <<~HERE
          date,count
          2018-05-31,20
          2018-06-30,10
        HERE
        expect(csv).to eq(expected_csv)
      end
    end
  end
end
