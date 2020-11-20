# frozen_string_literal: true

require "rails_helper"

RSpec.describe Org::CreateLastMonthJoinedUserService do
  let(:org) do
    FactoryBot.create(:org, created_at: DateTime.new(2018, 0o4, 0o1))
  end
  before(:each) do
    5.times do
      FactoryBot.create(:user, org: org, created_at: Date.today.last_month)
    end
    @last_day_of_month = Date.today.last_month.end_of_month
  end
  describe ".call" do
    context "when an org is passed" do
      it "generates counts from today's last month" do
        described_class.call(org)

        last_month = StatJoinedUser.find_by(date: @last_day_of_month, org_id: org.id).count
        expect(last_month).to eq(5)
      end

      it "monthly records are either created or updated" do
        described_class.call(org)

        FactoryBot.create(:user, org: org, created_at: Date.today.last_month)

        described_class.call(org)

        last_month_updated = StatJoinedUser.where(date: @last_day_of_month, org: org.id)
        expect(last_month_updated).to have(1).items
        expect(last_month_updated.first.count).to eq(6)
      end
    end

    context "when no org is passed" do
      it "generates counts from today's last month" do
        Org.stubs(:all).returns([org])

        described_class.call

        last_month = StatJoinedUser.find_by(date: @last_day_of_month, org_id: org.id).count
        expect(last_month).to eq(5)
      end

      it "generates counts by template from today's last month" do
        Org.stubs(:all).returns([org])

        described_class.call(org)

        FactoryBot.create(:user, org: org, created_at: Date.today.last_month)

        described_class.call(org)

        last_month_updated = StatJoinedUser.where(date: @last_day_of_month, org: org.id)
        expect(last_month_updated).to have(1).items
        expect(last_month_updated.first.count).to eq(6)
      end
    end
  end
end
