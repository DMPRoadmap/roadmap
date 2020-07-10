# frozen_string_literal: true

require "rails_helper"

RSpec.describe Org::CreateJoinedUserService do
  let(:org) do
    FactoryBot.create(:org, created_at: DateTime.new(2018, 0o4, 0o1))
  end

  before(:each) do
    FactoryBot.create(:user, org: org, created_at: DateTime.new(2018, 0o4, 0o3, 0, 0, 0))
    FactoryBot.create(:user, org: org, created_at: DateTime.new(2018, 0o4, 0o4, 0, 0, 0))
    FactoryBot.create(:user, org: org, created_at: DateTime.new(2018, 0o5, 0o3, 0, 0, 0))
    FactoryBot.create(:user, org: org, created_at: DateTime.new(2018, 0o6, 0o3, 0, 0, 0))
    FactoryBot.create(:user, org: org, created_at: DateTime.new(2018, 0o6, 0o4, 0, 0, 0))
    @dates = %w[2018-04-30 2018-05-31 2018-06-30 2018-07-31]
  end

  def find_by_dates(dates:, org_id:)
    dates.map do |date|
      StatJoinedUser.find_by(date: date, org_id: org_id)
    end
  end
  describe ".call" do
    context "when an org is passed" do
      it "generates monthly aggregates since org's creation" do
        described_class.call(org)
        april, may, june, july = find_by_dates(dates: @dates, org_id: org.id)
        counts = [april, may, june, july].map(&:count)
        expect(counts).to eq([2, 1, 2, 0])
      end

      it "monthly records are either created or updated" do
        described_class.call(org)

        FactoryBot.create(:user, org: org, created_at: DateTime.new(2018, 0o4, 0o5, 0, 0, 0))

        described_class.call(org)

        stat_joined_user = StatJoinedUser.where(date: "2018-04-30", org_id: org.id)
        expect(stat_joined_user).to have(1).items
        expect(stat_joined_user.first.count).to eq(3)
      end
    end

    context "when no org is passed" do
      it "generates monthly aggregates for each org since their creation" do
        Org.stubs(:all).returns([org])

        described_class.call

        april, may, june, july = find_by_dates(dates: @dates, org_id: org.id)
        counts = [april, may, june, july].map(&:count)
        expect(counts).to eq([2, 1, 2, 0])
      end

      it "monthly records are either created or updated" do
        Org.stubs(:all).returns([org])

        described_class.call

        FactoryBot.create(:user, org: org, created_at: DateTime.new(2018, 0o4, 0o5, 0, 0, 0))

        described_class.call

        stat_joined_user = StatJoinedUser.where(date: "2018-04-30", org_id: org.id)
        expect(stat_joined_user).to have(1).items
        expect(stat_joined_user.first.count).to eq(3)
      end
    end
  end
end
