# frozen_string_literal: true

require "rails_helper"

RSpec.describe SuperAdmin::ApiClientPolicy, type: :policy do
  context "authorize checks" do
    it "index?" do
      ensure_only_super_admin_access(action: :index)
    end
    it "edit?" do
      ensure_only_super_admin_access(action: :edit)
    end
    it "new?" do
      ensure_only_super_admin_access(action: :new)
    end
    it "create?" do
      ensure_only_super_admin_access(action: :create)
    end
    it "update?" do
      ensure_only_super_admin_access(action: :update)
    end
    it "destroy?" do
      ensure_only_super_admin_access(action: :destroy)
    end
    it "refresh_credentials?" do
      ensure_only_super_admin_access(action: :refresh_credentials)
    end
    it "email_credentials?" do
      ensure_only_super_admin_access(action: :email_credentials)
    end
  end

  # rubocop:disable Metrics/AbcSize
  def ensure_only_super_admin_access(action:)
    policy = described_class.new(create(:user), ApiClient)
    expect(policy).not_to permit_action(action.to_sym), "expected User to not have access"

    policy = described_class.new(create(:user, :org_admin), ApiClient)
    expect(policy).not_to permit_action(action.to_sym), "expected OrgAdmin to not have access"

    policy = described_class.new(create(:user, :super_admin), ApiClient)
    expect(policy).to permit_action(action.to_sym), "expected SuperAdmin to have access"
  end
  # rubocop:enable Metrics/AbcSize
end
