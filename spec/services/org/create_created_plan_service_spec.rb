require 'rails_helper'

RSpec.describe Org::CreateCreatedPlanService do
  let(:org) do
    FactoryBot.create(:org, created_at: DateTime.new(2018,04,01))
  end
  let(:template) do
    FactoryBot.create(:template, org: org)
  end
  let(:template2) do
    FactoryBot.create(:template, org: org)
  end
  let(:user1) do
    FactoryBot.create(:user, org: org)
  end
  let(:user2) do
    FactoryBot.create(:user, org: org)
  end
  #let(:creator) { Role.access_values_for(:creator).first }
  #let(:administrator) { Role.access_values_for(:administrator).first }
  before(:each) do
    plan = FactoryBot.create(:plan, template: template, created_at: DateTime.new(2018,04,01))
    plan2 = FactoryBot.create(:plan, template: template2, created_at: DateTime.new(2018,04,03))
    plan3 = FactoryBot.create(:plan, template: template, created_at: DateTime.new(2018,05,02))
    plan4 = FactoryBot.create(:plan, template: template, created_at: DateTime.new(2018,06,02))
    plan5 = FactoryBot.create(:plan, template: template2, created_at: DateTime.new(2018,06,03))
    FactoryBot.create(:role, :creator, plan: plan, user: user1)
    FactoryBot.create(:role, :administrator, plan: plan, user: user2)
    FactoryBot.create(:role, :creator, plan: plan2, user: user1)
    FactoryBot.create(:role, :creator, plan: plan3, user: user1)
    FactoryBot.create(:role, :administrator, plan: plan4, user: user2)
    FactoryBot.create(:role, :administrator, plan: plan5, user: user2)
  end

  def find_by_dates(dates: , org_id:)
    dates.map do |date|
      StatCreatedPlan.find_by(date: date, org_id: org_id)
    end
  end

  describe '.call' do
    context 'when org is passed' do
      it "generates monthly counts since org's creation" do
        described_class.call(org)

        april, may, june, july = find_by_dates(dates: ['2018-04-30', '2018-05-31', '2018-06-30', '2018-07-31'], org_id: org.id)
        counts = [april, may, june, july].map(&:count)
        expect(counts).to eq([2,1,2,0])
      end

      it "generates monthly counts by template since org's creation" do
        described_class.call(org)

        april, may, june, july = find_by_dates(dates: ['2018-04-30', '2018-05-31', '2018-06-30', '2018-07-31'], org_id: org.id)
        expect(april.details).to eq(
          {
            'by_template' => [
              { 'name' => template.title, 'count' => 1 },
              { 'name' => template2.title, 'count' => 1 },
            ]
          }
        )
        expect(may.details).to eq(
          {
            'by_template' => [
              { 'name' => template.title, 'count' => 1 },
            ]
          }
        )
        expect(june.details).to eq(
          {
            'by_template' => [
              { 'name' => template.title, 'count' => 1 },
              { 'name' => template2.title, 'count' => 1 },
            ]
          }
        )
        expect(july.details).to eq(
          {
            'by_template' => []
          }
        )
      end

      it "monthly records are either created or updated" do
        described_class.call(org)

        april = StatCreatedPlan.where(date: '2018-04-30', org: org)
        expect(april).to have(1).items
        expect(april.first.count).to eq(2)

        new_plan = FactoryBot.create(:plan, template: template2, created_at: DateTime.new(2018,04,03))
        FactoryBot.create(:role, :creator, plan: new_plan, user: user1)

        described_class.call(org)

        april = StatCreatedPlan.where(date: '2018-04-30', org: org)
        expect(april).to have(1).items
        expect(april.first.count).to eq(3)
      end
    end

    context 'when no org is passed' do
      it 'generates monthly counts for each org since their creation' do
        Org.stubs(:all).returns([org])

        described_class.call

        april, may, june, july = find_by_dates(dates: ['2018-04-30', '2018-05-31', '2018-06-30', '2018-07-31'], org_id: org.id)

        counts = [april, may, june, july].map(&:count)
        expect(counts).to eq([2,1,2,0])
      end

      it 'generates montly counts by template for each org since their creation' do
        Org.stubs(:all).returns([org])

        described_class.call

        april, may, june, july = find_by_dates(dates: ['2018-04-30', '2018-05-31', '2018-06-30', '2018-07-31'], org_id: org.id)

        expect(april.details).to eq(
          {
            'by_template' => [
              { 'name' => template.title, 'count' => 1 },
              { 'name' => template2.title, 'count' => 1 },
            ]
          }
        )
        expect(may.details).to eq(
          {
            'by_template' => [
              { 'name' => template.title, 'count' => 1 },
            ]
          }
        )
        expect(june.details).to eq(
          {
            'by_template' => [
              { 'name' => template.title, 'count' => 1 },
              { 'name' => template2.title, 'count' => 1 },
            ]
          }
        )
        expect(july.details).to eq(
          {
            'by_template' => []
          }
        )
      end

      it "monthly records are either created or updated" do
        Org.stubs(:all).returns([org])

        described_class.call

        april = StatCreatedPlan.where(date: '2018-04-30', org: org)
        expect(april).to have(1).items
        expect(april.first.count).to eq(2)

        new_plan = FactoryBot.create(:plan, template: template2, created_at: DateTime.new(2018,04,03))
        FactoryBot.create(:role, :creator, plan: new_plan, user: user1)

        described_class.call

        april = StatCreatedPlan.where(date: '2018-04-30', org: org)
        expect(april).to have(1).items
        expect(april.first.count).to eq(3)
      end
    end
  end
end
