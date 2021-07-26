# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::FundingPresenter do

  describe "#status(plan:)" do
    it "returns `planned` if the plan is nil" do
      expect(described_class.status(plan: nil)).to eql("planned")
    end
    it "returns `planned` if the plan's grant_number is nil" do
      plan = build(:plan, grant_number: nil)
      expect(described_class.status(plan: plan)).to eql("planned")
    end
    it "returns `granted` if the plan has a grant_number" do
      plan = build(:plan, grant_number: Faker::Lorem.word)
      expect(described_class.status(plan: plan)).to eql("granted")
    end
  end

end
