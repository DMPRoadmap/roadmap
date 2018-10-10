require 'rails_helper'
require_relative '../../../app/actions/stat_created_plan/generate'

RSpec.describe Actions::StatCreatedPlan::Generate do
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
  describe '.full' do
    it "returns monthly aggregates since org's creation" do
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

      described_class.full(org)

      april = StatCreatedPlan.find_by(date: '2018-04-30', org_id: org.id).count
      may = StatCreatedPlan.find_by(date: '2018-05-31', org_id: org.id).count
      june = StatCreatedPlan.find_by(date: '2018-06-30', org_id: org.id).count
      july = StatCreatedPlan.find_by(date: '2018-07-31', org_id: org.id).count
            
      expect([april, may, june, july]).to eq([2,1,2,0])
    end
  end

  describe '.last_month' do
    it "returns aggregates from today's last month" do
      plan = FactoryBot.create(:plan, created_at: Date.today.last_month)
      plan2 = FactoryBot.create(:plan, created_at: Date.today.last_month)
      plan3 = FactoryBot.create(:plan, created_at: Date.today.last_month)
      FactoryBot.create(:role, plan: plan, user: user1, access: creator)
      FactoryBot.create(:role, plan: plan, user: user1, access: administrator)
      FactoryBot.create(:role, plan: plan2, user: user1, access: creator)
      FactoryBot.create(:role, plan: plan3, user: user2, access: creator)

      described_class.last_month(org)

      last_month = StatCreatedPlan.find_by(date: Date.today.last_month.end_of_month, org_id: org.id).count
      expect(last_month).to eq(3)
    end  
  end

  describe '.full_all_orgs' do
    it 'returns monthly aggregates for each org since their creation' do
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

      described_class.full_all_orgs

      april = StatCreatedPlan.find_by(date: '2018-04-30', org_id: org.id).count
      may = StatCreatedPlan.find_by(date: '2018-05-31', org_id: org.id).count
      june = StatCreatedPlan.find_by(date: '2018-06-30', org_id: org.id).count
      july = StatCreatedPlan.find_by(date: '2018-07-31', org_id: org.id).count
            
      expect([april, may, june, july]).to eq([2,1,2,0])
    end
  end

  describe '.last_month_all_orgs' do
    it "returns aggregates from today's last month" do
      Org.expects(:all).returns([org])
      plan = FactoryBot.create(:plan, created_at: Date.today.last_month)
      plan2 = FactoryBot.create(:plan, created_at: Date.today.last_month)
      plan3 = FactoryBot.create(:plan, created_at: Date.today.last_month)
      FactoryBot.create(:role, plan: plan, user: user1, access: creator)
      FactoryBot.create(:role, plan: plan, user: user1, access: administrator)
      FactoryBot.create(:role, plan: plan2, user: user1, access: creator)
      FactoryBot.create(:role, plan: plan3, user: user2, access: creator)

      described_class.last_month_all_orgs

      last_month = StatCreatedPlan.find_by(date: Date.today.last_month.end_of_month, org_id: org.id).count
      expect(last_month).to eq(3)
    end
  end
end
