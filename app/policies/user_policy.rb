# frozen_string_literal: true

# Security rules for users
# Note the method names here correspond with controller actions
class UserPolicy < ApplicationPolicy
  def index?
    admin_index?
  end

  def admin_index?
    @user.can_grant_permissions?
  end

  def admin_grant_permissions?
    (@user.can_grant_permissions? && user.org_id == @user.org_id) ||
      @user.can_super_admin?
  end

  def admin_update_permissions?
    (@user.can_grant_permissions? && user.org_id == @user.org_id) ||
      @user.can_super_admin?
  end

  # Allows the user to swap their org affiliation on the fly
  def org_swap?
    @user.can_super_admin?
  end

  def activate?
    @user.can_super_admin?
  end

  def confirm_user?
    @user.can_super_admin? || @user.can_org_admin?
  end

  def edit?
    @user.can_super_admin? || @user.can_org_admin?
  end

  def update?
    @user.can_super_admin? || @user.can_org_admin?
  end

  def user_plans?
    @user.can_super_admin? || @user.can_org_admin?
  end

  def update_email_preferences?
    true
  end

  def acknowledge_notification?
    true
  end

  def refresh_token?
    @user.can_super_admin? ||
      (@user.can_org_admin? && @user.can_use_api?)
  end

  def merge?
    @user.can_super_admin?
  end

  def archive?
    @user.can_super_admin?
  end

  def search?
    @user.can_super_admin?
  end

  def org_admin_other_user?
    @user.can_super_admin? || @user.can_org_admin?
  end

  # returns the users for the org
  class Scope < Scope
    def resolve
      @scope.where(org_id: @user.org_id)
    end
  end
end
