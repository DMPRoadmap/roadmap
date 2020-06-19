# frozen_string_literal: true

require "rails_helper"

RSpec.describe Org::CreateLastMonthCreatedPlanService do
  let(:org) do
    FactoryBot.create(:org, created_at: DateTime.new(2018, 04, 01))
  end
  let(:org2) do
    FactoryBot.create(:org)
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
  let(:user3) do
    FactoryBot.create(:user, org: org2)
  end
  let(:creator) { Role.access_values_for(:creator).first }
  let(:administrator) { Role.access_values_for(:administrator).first }
  before(:each) do
    plan = FactoryBot.create(:plan,
                             template: template,
                             created_at: Date.today.last_month)
    plan2 = FactoryBot.create(:plan,
                              template: template,
                              created_at: Date.today.last_month)
    plan3 = FactoryBot.create(:plan,
                              template: template2,
                              created_at: Date.today.last_month)
    plan4 = FactoryBot.create(:plan,
                              template: template2,
                              created_at: Date.today.last_month)
    FactoryBot.create(:role, :creator, plan: plan, user: user1)
    FactoryBot.create(:role, :administrator, plan: plan, user: user1)
    FactoryBot.create(:role, :creator, plan: plan2, user: user1)
    FactoryBot.create(:role, :creator, plan: plan3, user: user2)
    FactoryBot.create(:role, :creator, plan: plan4, user: user3)
  end

  describe ".call" do
    context "when org is passed" do
      it "generates counts from today's last month" do
        described_class.call(org)

        last_month_count = StatCreatedPlan.find_by(
          date: Date.today.last_month.end_of_month,
          org_id: org.id, filtered: false).count
        expect(last_month_count).to eq(3)
      end

      it "generates counts by template from today's last month" do
        described_class.call(org)

        last_month_details = StatCreatedPlan.find_by(
          date: Date.today.last_month.end_of_month,
          org_id: org.id, filtered: false).by_template

        expect(last_month_details).to match_array(
          [
            { "name" => template.title, "count" => 2 },
            { "name" => template2.title, "count" => 1 },
          ]
        )
      end

      it "generates counts using template from today's last month" do
        described_class.call(org)

        last_month_details = StatCreatedPlan.find_by(
          date: Date.today.last_month.end_of_month,
          org_id: org.id, filtered: false).using_template

        expect(last_month_details).to match_array(
          [
            { "name" => template.title, "count" => 2 },
            { "name" => template2.title, "count" => 2 },
          ]
        )
      end

      it "monthly records are either created or updated" do
        described_class.call(org)

        last_month = StatCreatedPlan.where(
          date: Date.today.last_month.end_of_month,
          org_id: org.id, filtered: false)

        expect(last_month).to have(1).items
        expect(last_month.first.count).to eq(3)

        new_plan = FactoryBot.create(:plan,
                                     template: template2,
                                     created_at: Date.today.last_month.end_of_month)
        FactoryBot.create(:role, :creator, plan: new_plan, user: user1)

        described_class.call(org)

        last_month = StatCreatedPlan.where(
          date: Date.today.last_month.end_of_month,
          org_id: org.id, filtered: false)

        expect(last_month).to have(1).items
        expect(last_month.first.count).to eq(4)
      end
    end

    context "when no org is passed" do
      it "generates counts from today's last month" do
        Org.expects(:all).returns([org])

        described_class.call

        last_month_count = StatCreatedPlan.find_by(
          date: Date.today.last_month.end_of_month,
          org_id: org.id, filtered: false).count

        expect(last_month_count).to eq(3)
      end

      it "generates counts by template from today's last month" do
        Org.expects(:all).returns([org])

        described_class.call

        last_month_details = StatCreatedPlan.find_by(
          date: Date.today.last_month.end_of_month,
          org_id: org.id, filtered: false).by_template

        expect(last_month_details).to match_array(
          [
            { "name" => template.title, "count" => 2 },
            { "name" => template2.title, "count" => 1 },
          ]
        )
      end

      it "generates counts using template from today's last month" do
        Org.expects(:all).returns([org])

        described_class.call

        last_month_details = StatCreatedPlan.find_by(
          date: Date.today.last_month.end_of_month,
          org_id: org.id, filtered: false).using_template

        expect(last_month_details).to match_array(
          [
            { "name" => template.title, "count" => 2 },
            { "name" => template2.title, "count" => 2 },
          ]
        )
      end

      it "monthly records are either created or updated" do
        Org.stubs(:all).returns([org])

        described_class.call

        last_month = StatCreatedPlan.where(
          date: Date.today.last_month.end_of_month,
          org: org, filtered: false)

        expect(last_month).to have(1).items
        expect(last_month.first.count).to eq(3)

        new_plan = FactoryBot.create(:plan,
                                     template: template2,
                                     created_at: Date.today.last_month.end_of_month)
        FactoryBot.create(:role, :creator, plan: new_plan, user: user1)

        described_class.call

        last_month = StatCreatedPlan.where(date: Date.today.last_month.end_of_month,
                                           org: org, filtered: false)
        expect(last_month).to have(1).items
        expect(last_month.first.count).to eq(4)
      end
    end
  end
end
