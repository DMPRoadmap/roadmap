# frozen_string_literal: true
<<<<<<< HEAD

class UserPolicy < ApplicationPolicy

  attr_reader :signed_in_user
  attr_reader :user

  def initialize(signed_in_user, user)
    raise Pundit::NotAuthorizedError, "must be logged in" unless signed_in_user

    @signed_in_user = signed_in_user
    @user = user
  end

=======

# Security rules for users
# Note the method names here correspond with controller actions
class UserPolicy < ApplicationPolicy
>>>>>>> upstream/master
  def index?
    admin_index?
  end

  def admin_index?
    signed_in_user.can_grant_permissions?
  end

  def admin_grant_permissions?
<<<<<<< HEAD
    (signed_in_user.can_grant_permissions? && user.org_id == signed_in_user.org_id) ||
      signed_in_user.can_super_admin?
  end

  def admin_update_permissions?
    (signed_in_user.can_grant_permissions? && user.org_id == signed_in_user.org_id) ||
      signed_in_user.can_super_admin?
=======
    (@user.can_grant_permissions? && user.org_id == @user.org_id) ||
      @user.can_super_admin?
  end

  def admin_update_permissions?
    (@user.can_grant_permissions? && user.org_id == @user.org_id) ||
      @user.can_super_admin?
>>>>>>> upstream/master
  end

  # Allows the user to swap their org affiliation on the fly
  def org_swap?
<<<<<<< HEAD
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
=======
    @user.can_super_admin?
  end

  def activate?
    @user.can_super_admin?
  end

  def edit?
    @user.can_super_admin? || @user.can_org_admin?
  end

  def update?
    @user.can_super_admin? || @user.can_org_admin?
  end

  def user_plans?
    @user.can_super_admin? || @user.can_org_admin?
>>>>>>> upstream/master
  end

  def update_email_preferences?
    true
<<<<<<< HEAD
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
=======
>>>>>>> upstream/master
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
<<<<<<< HEAD

=======
>>>>>>> upstream/master
end
