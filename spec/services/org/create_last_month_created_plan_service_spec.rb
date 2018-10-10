require 'rails_helper'

RSpec.describe Org::CreateLastMonthCreatedPlanService do
  let(:org) do
    FactoryBot.create(:org, created_at: DateTime.new(2018,04,01))
  end
  let(:user1) do
    FactoryBot.create(:user, org: org)
  end
  let(:user2) do
    FactoryBot.create(:user, org: org)
  end
  let(:creator) { Role.access_values_for(:creator).first }
  let(:administrator) { Role.access_values_for(:administrator).first }

  describe '.call' do
    context 'when org is passed' do
      it "returns aggregates from today's last month" do
        plan = FactoryBot.create(:plan, created_at: Date.today.last_month)
        plan2 = FactoryBot.create(:plan, created_at: Date.today.last_month)
        plan3 = FactoryBot.create(:plan, created_at: Date.today.last_month)
        FactoryBot.create(:role, plan: plan, user: user1, access: creator)
        FactoryBot.create(:role, plan: plan, user: user1, access: administrator)
        FactoryBot.create(:role, plan: plan2, user: user1, access: creator)
        FactoryBot.create(:role, plan: plan3, user: user2, access: creator)

        described_class.call(org)

        last_month = StatCreatedPlan.find_by(date: Date.today.last_month.end_of_month, org_id: org.id).count
        expect(last_month).to eq(3)
      end
    end
    
    context 'when no org is passed' do
      it "returns aggregates from today's last month" do
        Org.expects(:all).returns([org])
        plan = FactoryBot.create(:plan, created_at: Date.today.last_month)
        plan2 = FactoryBot.create(:plan, created_at: Date.today.last_month)
        plan3 = FactoryBot.create(:plan, created_at: Date.today.last_month)
        FactoryBot.create(:role, plan: plan, user: user1, access: creator)
        FactoryBot.create(:role, plan: plan, user: user1, access: administrator)
        FactoryBot.create(:role, plan: plan2, user: user1, access: creator)
        FactoryBot.create(:role, plan: plan3, user: user2, access: creator)

        described_class.call

        last_month = StatCreatedPlan.find_by(date: Date.today.last_month.end_of_month, org_id: org.id).count
        expect(last_month).to eq(3)
      end
    end
  end
end
