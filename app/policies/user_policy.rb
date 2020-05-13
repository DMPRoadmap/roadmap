class UserPolicy < ApplicationPolicy
  attr_reader :signed_in_user
  attr_reader :user

  def initialize(signed_in_user, user)
    raise Pundit::NotAuthorizedError, "must be logged in" unless signed_in_user
    @signed_in_user = signed_in_user
    @user = user
  end

  def index?
    admin_index?
  end

  def admin_index?
    signed_in_user.can_grant_permissions?
  end

  def admin_grant_permissions?
    (signed_in_user.can_grant_permissions? && user.org_id == signed_in_user.org_id) || signed_in_user.can_super_admin?
  end

  def admin_update_permissions?
    (signed_in_user.can_grant_permissions? && user.org_id == signed_in_user.org_id) || signed_in_user.can_super_admin?
  end

  # Allows the user to swap their org affiliation on the fly
  def org_swap?
    signed_in_user.can_change_org?
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

  class Scope < Scope
    def resolve
      scope.where(org_id: user.org_id)
    end
  end
end
