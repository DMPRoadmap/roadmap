# frozen_string_literal: true

require "rails_helper"

RSpec.describe UsagePolicy, type: :policy do

  subject { described_class.new(user, :usage) }

  let(:super_actions) do
    %i[index filter global_statistics yearly_users yearly_plans
       all_plans_by_template plans_by_template org_statistics]
  end
  let(:org_actions) do
    %i[index filter yearly_users yearly_plans
       all_plans_by_template plans_by_template org_statistics]
  end

  context "super_admin" do
    let(:user) { create(:user, :super_admin) }
    it "has access to all actions" do
      is_expected.to permit_actions(super_actions)
    end
  end

  context "org_admin" do
    let(:user) { create(:user, :org_admin) }
    it "has access to all org-admin actions" do
      is_expected.to permit_actions(org_actions)
    end

    it "does not have access to global statistics" do
      is_expected.to forbid_actions(%i[global_statistics])
    end
  end

  context "user" do
    let(:user) { create(:user) }
    it "not have access to any of the actions" do
      is_expected.to forbid_actions(super_actions)
    end
  end

  context "unauthenticated" do
    let(:user) { nil }
    it "not have access to any of the actions" do
      super_actions.each do |action|
        # rubocop:disable Layout/LineLength
        expect { is_expected.to permit_action(action) }.to raise_error(Pundit::NotAuthorizedError), "expected :#{action} to raise a NotAuthorizedError"
        # rubocop:enable Layout/LineLength
      end
    end
  end
end
