# frozen_string_literal: true

require "rails_helper"

RSpec.describe Org::TotalCountStatService do
  describe ".do" do
    it "returns the total stats for each org" do
      Org::TotalCountJoinedUserService.stubs(:call).returns([
                                                              { org_name: "Org 1", count: 10 },
                                                              { org_name: "Org 2", count: 20 }
                                                            ])
      Org::TotalCountCreatedPlanService.stubs(:call).returns([
                                                               { org_name: "Org 2", count: 10 },
                                                               { org_name: "Org 3", count: 15 }
                                                             ])

      totals = described_class.call

      expect(totals).to include(
        { org_name: "Org 1", total_users: 10, total_plans: 0 },
        { org_name: "Org 2", total_users: 20, total_plans: 10 },
        { org_name: "Org 3", total_users: 0, total_plans: 15 }
      )
    end
  end
end
