# frozen_string_literal: true

# File for DMP Assistant upgrade tasks, beginning with release 4.1.1+portage-4.2.3

# rubocop:disable Naming/VariableNumber
namespace :dmp_assistant_upgrade do
  desc 'Upgrade to DMP Assistant 4.1.1+portage-4.2.3'
  task v4_2_3: :environment do
    p '------------------------------------------------------------------------'
    p 'Executing upgrade tasks for DMP Assistant 4.1.1+portage-4.2.3'
    p 'Beginning task: Handle email confirmations for existing users'
    p '------------------------------------------------------------------------'
    handle_email_confirmations_for_existing_users
    p 'Task completed: Handle email confirmations for existing users'
    p 'All tasks completed successfully'
  end
  # rubocop:enable Naming/VariableNumber

  private

  def handle_email_confirmations_for_existing_users
    p 'Updating :confirmable columns to nil for all users'
    p '(i.e. Setting confirmed_at, confirmation_token, and confirmation_sent_at to nil for all users)'
    p '------------------------------------------------------------------------'
    set_confirmable_cols_to_nil_for_all_users
    p '------------------------------------------------------------------------'
    p 'Updating superusers so that they are not required to confirm their email addresses'
    p '(i.e. Setting `confirmed_at = Time.now`` for superusers)'
    p '------------------------------------------------------------------------'
    confirm_superusers
  end

  # Setting `confirmed_at` to nil will require users to confirm their email addresses when using :confirmable
  # Setting `confirmation_token` to nil will improve the email confirmation-related UX flow for existing users
  # For more info regarding this improved UX flow, see app/controllers/concerns/email_confirmation_handler.rb
  def set_confirmable_cols_to_nil_for_all_users
    count = User.update_all(confirmed_at: nil, confirmation_token: nil, confirmation_sent_at: nil)
    p ":confirmable columns updated to nil for #{count} users"
  end

  # Sets `confirmed_at` to `Time.now` for all superusers
  def confirm_superusers
    confirmed_at = Time.now
    count = User.joins(:perms).where(perms: { id: super_admin_perm_ids })
                .distinct
                .update_all(confirmed_at: confirmed_at)
    p "Updated confirmed_at = #{confirmed_at} for #{count} superuser(s)"
  end

  # Returns an array of all perm ids that are considered super admin perms
  # (Based off of `def can_super_admin?`` in `app/models/user.rb`
  # i.e. `can_add_orgs? || can_grant_api_to_orgs? || can_change_org?` )
  def super_admin_perm_ids
    [Perm.add_orgs.id, Perm.grant_api.id, Perm.change_affiliation.id]
  end
end
