require 'rails_helper'

RSpec.describe Org::CreateLastMonthJoinedUserService do
  let(:org) do
    FactoryBot.create(:org, created_at: DateTime.new(2018,04,01))
  end
  describe '.call' do
    context 'when an org is passed' do
      it "generates aggregates from today's last month" do
        5.times do
          FactoryBot.create(:user, org: org, created_at: Date.today.last_month)
        end

        described_class.call(org)

        last_month = StatJoinedUser.find_by(date: Date.today.last_month.end_of_month, org_id: org.id).count
        expect(last_month).to eq(5)
      end
    end

    context 'when no org is passed' do
      it "generates aggregates from today's last month" do
        Org.expects(:all).returns([org])
        5.times do
          FactoryBot.create(:user, org: org, created_at: Date.today.last_month)
        end

        described_class.call

        last_month = StatJoinedUser.find_by(date: Date.today.last_month.end_of_month, org_id: org.id).count
        expect(last_month).to eq(5)
      end
    end
  end
end
