# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrgDateRangeable do
  let(:org) do
    FactoryBot.create(:org, created_at: DateTime.new(2018, 0o5, 28, 0, 0, 0))
  end

  describe ".monthly_range" do
    context "when org keyword param is missing" do
      it "returns ArgumentError" do
        expect do
          StatJoinedUser.monthly_range
        end.to raise_error(ArgumentError, /missing keyword: org/)
      end
    end

    context "when start_date is nil" do
      it "returns every record whose date <= end_date" do
        FactoryBot.create(:stat_joined_user, date: "2018-06-30", org: org, count: 10)
        FactoryBot.create(:stat_joined_user, date: "2018-07-31", org: org, count: 10)

        result = StatJoinedUser.monthly_range(org: org, end_date: "2018-06-30")

        expected_result = StatJoinedUser.where(org: org, date: "2018-06-30")
        expect(result.map(&:attributes)).to eq(expected_result.map(&:attributes))
      end
    end

    context "when end_date is nil" do
      it "returns every record whose date >= start_date" do
        FactoryBot.create(:stat_joined_user, date: "2018-06-30", org: org, count: 10)
        FactoryBot.create(:stat_joined_user, date: "2018-07-31", org: org, count: 10)

        result = StatJoinedUser.monthly_range(org: org, start_date: "2018-07-31")

        expected_result = StatJoinedUser.where(org: org, date: "2018-07-31")
        expect(result.map(&:attributes)).to eq(expected_result.map(&:attributes))
      end
    end

    context "when all keyword are passed" do
      it "returns every record within start_date and end_date" do
        FactoryBot.create(:stat_joined_user, date: "2018-06-30", org: org, count: 10)
        FactoryBot.create(:stat_joined_user, date: "2018-07-31", org: org, count: 10)

        result = StatJoinedUser.monthly_range(org: org, start_date: "2018-06-30", end_date: "2018-07-31")

        expected_result = StatJoinedUser.where("org_id = ? and date >= ? and date <= ?", org.id, "2018-06-30", "2018-07-31")
        expect(result.map(&:attributes)).to eq(expected_result.map(&:attributes))
      end
    end
  end

  describe ".split_months_from_creation" do
    it "starts at org's created_at" do
      expected_date = DateTime.new(2018, 0o5, 28, 0, 0, 0)

      described_class.split_months_from_creation(org) do |start_date, _end_date|
        expect(start_date).to eq(expected_date)
        break
      end
    end

    it "finishes at today's last month" do
      expected_date = DateTime.current.last_month.end_of_month.to_i
      actual_date = nil

      described_class.split_months_from_creation(org) do |_start_date, end_date|
        actual_date = end_date.to_i
      end

      expect(actual_date).to eq(expected_date)
    end

    context "when is an Enumerable" do
      subject { described_class.split_months_from_creation(org) }

      it "responds to each method" do
        is_expected.to respond_to(:each)
      end

      it "starts at org's created_at" do
        first = subject.first
        start_date = org.created_at
        end_date = DateTime.new(2018, 0o5, 31, 23, 59, 59).to_i

        expect(first[:start_date]).to eq(start_date)
        expect(first[:end_date].to_i).to eq(end_date)
      end
    end
  end
end
