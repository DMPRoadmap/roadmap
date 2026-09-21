# frozen_string_literal: true

namespace :email_confirmation do
  desc 'Reset confirmation status for all users, excluding superusers'
  task clear_all: :environment do
    p '------------------------------------------------------------------------'
    p 'Beginning task: Unconfirming all users except superusers'
    p '------------------------------------------------------------------------'
    unconfirm_all_users_except_superusers
    p 'Task completed: Unconfirmed all users except superusers'
  end

  private

  def unconfirm_all_users_except_superusers
    p 'Updating :confirmable columns to nil for all users'
    p '(i.e. Setting confirmed_at, confirmation_token, and confirmation_sent_at to nil for all users)'
    p '------------------------------------------------------------------------'
    set_confirmable_cols_to_nil_for_all_users
    p '------------------------------------------------------------------------'
    p 'Updating superusers so that they are not required to confirm their email addresses'
    p '(i.e. Setting `confirmed_at = Time.current` for superusers)'
    p '------------------------------------------------------------------------'
    confirm_superusers
  end

  def set_confirmable_cols_to_nil_for_all_users
    count = User.update_all(confirmed_at: nil, confirmation_token: nil, confirmation_sent_at: nil)
    p ":confirmable columns updated to nil for #{count} users"
  end

  # Sets `confirmed_at` to `Time.current` for all superusers
  def confirm_superusers
    confirmed_at = Time.current
    count = User.joins(:perms).where(perms: { id: super_admin_perm_ids })
                .distinct
                .update_all(confirmed_at: confirmed_at)
    p "Updated confirmed_at = #{confirmed_at} for #{count} superuser(s)"
  end

  # Returns an array of all perm ids that are considered super admin perms
  # (Based off of `def can_super_admin?` in `app/models/user.rb`
  # i.e. `can_add_orgs? || can_grant_api_to_orgs? || can_change_org?` )
  def super_admin_perm_ids
    [Perm.add_orgs.id, Perm.grant_api.id, Perm.change_affiliation.id]
  end
end
