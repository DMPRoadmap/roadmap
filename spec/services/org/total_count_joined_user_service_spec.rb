# frozen_string_literal: true

require "rails_helper"

RSpec.describe Org::TotalCountJoinedUserService do
  describe ".call" do
    let(:org) { create(:org, created_at: DateTime.new(2018, 6, 1, 0, 0, 0)) }
    let(:org2) { create(:org, created_at: DateTime.new(2018, 6, 1, 0, 0, 0)) }
    context "when org is passed" do
      it "returns the number of joined users" do
        create_stats(org)

        count = described_class.call(org)

        expect(count).to eq({ org_name: org.name, count: 60 })
      end
    end

    context "when org is NOT passed" do
      it "returns the number of joined users" do
        create_stats(org)
        create_stats(org2)

        count = described_class.call

        expect(count).to include(
          { org_name: org.name, count: 60 },
          { org_name: org2.name, count: 60 }
        )
      end
    end

    def create_stats(org)
      create(:stat_joined_user, date: Date.new(2018, 6, 30), org: org, count: 10)
      create(:stat_joined_user, date: Date.new(2018, 7, 31), org: org, count: 20)
      create(:stat_joined_user, date: Date.new(2018, 8, 31), org: org, count: 30)
    end
  end
end
