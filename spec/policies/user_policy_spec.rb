# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  subject(:policy) { described_class.new(actor, target) }

  let(:org) { create(:org) }
  let(:actor) { create(:user, :org_admin, org: org) }
  let(:target) { create(:user, org: org) }
  let(:record_actions) do
    %i[admin_grant_permissions admin_update_permissions edit update user_plans org_admin_other_user]
  end

  context 'when an organization admin manages a user in their organization' do
    it { is_expected.to permit_actions(record_actions) }
    it { is_expected.to forbid_actions(%i[super_admin_edit super_admin_update]) }
  end

  context 'when an organization admin manages a user in another organization' do
    let(:target) { create(:user) }

    it { is_expected.to forbid_actions(record_actions) }
  end

  context 'when an ordinary user manages a user in their organization' do
    let(:actor) { create(:user, org: org) }

    it { is_expected.to forbid_actions(record_actions) }
  end

  context 'when the caller only has template-management permission' do
    let(:actor) { create(:user, org: org, perms: [create(:perm, :modify_templates)]) }

    it { is_expected.to permit_actions(%i[edit update user_plans org_admin_other_user]) }
    it { is_expected.to forbid_actions(%i[admin_grant_permissions admin_update_permissions]) }

    context 'when the target belongs to another organization' do
      let(:target) { create(:user) }

      it { is_expected.to forbid_actions(record_actions) }
    end
  end

  context 'when the caller is a super admin' do
    let(:actor) { create(:user, perms: [create(:perm, :add_organisations)]) }

    it { is_expected.to permit_actions(record_actions + %i[super_admin_edit super_admin_update]) }
  end

  context 'when both users have no organization' do
    before do
      actor.org = nil
      target.org = nil
    end

    it { is_expected.to forbid_actions(record_actions) }
  end

  context 'when the target has no organization' do
    before { target.org = nil }

    it { is_expected.to forbid_actions(record_actions) }
  end

  context 'when the caller is not authenticated' do
    let(:actor) { nil }

    it 'requires authentication' do
      expect { policy }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context 'when a record-level check receives the User class' do
    let(:target) { User }

    it { is_expected.to forbid_actions(record_actions) }
  end

  context 'when the caller is the managed record' do
    let(:target) { actor }

    it { is_expected.to permit_actions(record_actions) }
  end

  it 'continues to authorize the organization user index with a class record' do
    expect(described_class.new(actor, User).admin_index?).to be(true)
  end
end
