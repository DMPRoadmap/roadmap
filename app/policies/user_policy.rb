# frozen_string_literal: true

# Security rules for users
# Note the method names here correspond with controller actions
class UserPolicy < ApplicationPolicy
  def index?
    admin_index?
  end

  def admin_index?
    signed_in_user.can_grant_permissions?
  end

  def admin_grant_permissions?
    (signed_in_user.can_grant_permissions? && user.org_id == signed_in_user.org_id) ||
      signed_in_user.can_super_admin?
  end

  def admin_update_permissions?
    (signed_in_user.can_grant_permissions? && user.org_id == signed_in_user.org_id) ||
      signed_in_user.can_super_admin?
  end

  # Allows the user to swap their org affiliation on the fly
  def org_swap?
    signed_in_user.can_super_admin?
  end

  def activate?
    signed_in_user.can_super_admin?
  end

  def edit?
    signed_in_user.can_super_admin? || signed_in_user.can_org_admin?
  end

  def update?
    signed_in_user.can_super_admin? || signed_in_user.can_org_admin?
  end

  def user_plans?
    signed_in_user.can_super_admin? || signed_in_user.can_org_admin?
  end

  def update_email_preferences?
    true
  end

  def acknowledge_notification?
    true
  end

  def refresh_token?
    signed_in_user.can_super_admin? ||
      (signed_in_user.can_org_admin? && signed_in_user.can_use_api?)
  end

  def merge?
    signed_in_user.can_super_admin?
  end

  def archive?
    signed_in_user.can_super_admin?
  end

  def search?
    signed_in_user.can_super_admin?
  end

  def org_admin_other_user?
    signed_in_user.can_super_admin? || signed_in_user.can_org_admin?
  end

  # returns the users for the org
  class Scope < Scope
    def resolve
      @scope.where(org_id: @user.org_id)
    end
  end
end
