require 'rails_helper'

RSpec.describe Org::CreateCreatedPlanService do
  let(:org) do
    FactoryBot.create(:org, created_at: DateTime.new(2018,04,01))
  end
  let(:template) do
    FactoryBot.create(:template, org: org)
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
      it "generates monthly aggregates since org's creation" do
        plan = FactoryBot.create(:plan, template: template, created_at: DateTime.new(2018,04,01))
        plan2 = FactoryBot.create(:plan, template: template, created_at: DateTime.new(2018,04,03))
        plan3 = FactoryBot.create(:plan, template: template, created_at: DateTime.new(2018,05,02))
        plan4 = FactoryBot.create(:plan, template: template, created_at: DateTime.new(2018,06,02))
        plan5 = FactoryBot.create(:plan, template: template, created_at: DateTime.new(2018,06,03))
        FactoryBot.create(:role, plan: plan, user: user1, access: creator)
        FactoryBot.create(:role, plan: plan, user: user2, access: administrator)
        FactoryBot.create(:role, plan: plan2, user: user1, access: creator)
        FactoryBot.create(:role, plan: plan3, user: user1, access: creator)
        FactoryBot.create(:role, plan: plan4, user: user2, access: administrator)
        FactoryBot.create(:role, plan: plan5, user: user2, access: administrator)

        described_class.call(org)

        april = StatCreatedPlan.find_by(date: '2018-04-30', org_id: org.id).count
        may = StatCreatedPlan.find_by(date: '2018-05-31', org_id: org.id).count
        june = StatCreatedPlan.find_by(date: '2018-06-30', org_id: org.id).count
        july = StatCreatedPlan.find_by(date: '2018-07-31', org_id: org.id).count

        expect([april, may, june, july]).to eq([2,1,2,0])
      end
    end

    context 'when no org is passed' do
      it 'generates monthly aggregates for each org since their creation' do
        Org.stubs(:all).returns([org])
        plan = FactoryBot.create(:plan, template: template, created_at: DateTime.new(2018,04,01))
        plan2 = FactoryBot.create(:plan, template: template, created_at: DateTime.new(2018,04,03))
        plan3 = FactoryBot.create(:plan, template: template, created_at: DateTime.new(2018,05,02))
        plan4 = FactoryBot.create(:plan, template: template, created_at: DateTime.new(2018,06,02))
        plan5 = FactoryBot.create(:plan, template: template, created_at: DateTime.new(2018,06,03))
        FactoryBot.create(:role, plan: plan, user: user1, access: creator)
        FactoryBot.create(:role, plan: plan, user: user2, access: administrator)
        FactoryBot.create(:role, plan: plan2, user: user1, access: creator)
        FactoryBot.create(:role, plan: plan3, user: user1, access: creator)
        FactoryBot.create(:role, plan: plan4, user: user2, access: administrator)
        FactoryBot.create(:role, plan: plan5, user: user2, access: administrator)

        described_class.call

        april = StatCreatedPlan.find_by(date: '2018-04-30', org_id: org.id).count
        may = StatCreatedPlan.find_by(date: '2018-05-31', org_id: org.id).count
        june = StatCreatedPlan.find_by(date: '2018-06-30', org_id: org.id).count
        july = StatCreatedPlan.find_by(date: '2018-07-31', org_id: org.id).count

        expect([april, may, june, july]).to eq([2,1,2,0])
      end
    end
  end
end
