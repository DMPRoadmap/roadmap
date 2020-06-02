# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContributorPolicy, type: :policy do
  context "authorize checks" do
    it "index?" do
      user = build(:user)
      plan = build(:plan)

      plan.stubs(:readable_by?).returns(false)
      policy = described_class.new(user, plan)
      expect(policy).not_to permit_action(:index), "expected to not have access"

      plan.stubs(:readable_by?).returns(true)
      policy = described_class.new(user, plan)
      expect(policy).to permit_action(:index), "expected to have access"
    end
    it "new?" do
      ensure_administerable(action: :edit)
    end
    it "edit?" do
      ensure_administerable(action: :new)
    end
    it "create?" do
      ensure_administerable(action: :create)
    end
    it "update?" do
      ensure_administerable(action: :update)
    end
    it "destroy?" do
      ensure_administerable(action: :destroy)
    end
  end

  # rubocop:disable Metrics/AbcSize
  def ensure_administerable(action:)
    user = build(:user)
    plan = build(:plan)

    plan.stubs(:administerable_by?).returns(false)
    policy = described_class.new(user, plan)
    expect(policy).not_to permit_action(action.to_sym), "expected to not have access"

    plan.stubs(:administerable_by?).returns(true)
    policy = described_class.new(user, plan)
    expect(policy).to permit_action(action.to_sym), "expected to have access"
  end
  # rubocop:enable Metrics/AbcSize
end
