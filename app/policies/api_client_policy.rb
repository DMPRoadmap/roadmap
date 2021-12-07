# frozen_string_literal: true

# Security rules for API Clients
# Note the method names here correspond with controller actions
class ApiClientPolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user

  def index?
    @user.can_super_admin?
  end

  def new?
    @user.can_super_admin?
  end

  def create?
    # Super admin or the user can do this for themselves
    @user.can_super_admin? || @user.id == @record.user_id
  end

  def edit?
    @user.can_super_admin?
  end

  def update?
    # Super admin or the user can do this for themselves
    @user.can_super_admin? || @user.id == @record.user_id
  end

  def destroy?
    @user.can_super_admin?
  end

  def refresh_credentials?
    # Super admin or the user can do this for themselves
    @user.can_super_admin? || @user.id == @record.user_id
  end

  def email_credentials?
    @user.can_super_admin?
  end
end
