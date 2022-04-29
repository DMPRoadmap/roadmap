# frozen_string_literal: true

# Security rules for department editing
# Note the method names here correspond with controller actions
class DepartmentPolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of Department

  def index?
    (@user.can_org_admin? && @user.org.id == @department.org_id) ||
      @user.can_super_admin?
  end

  def new?
    @user.can_org_admin? || @user.can_super_admin?
  end

  def create?
    @user.can_org_admin? || @user.can_super_admin?
  end

  def edit?
    (@user.can_org_admin? && @user.org.id == @record.org_id) ||
      @user.can_super_admin?
  end

  def update?
    (@user.can_org_admin? && @user.org.id == @record.org_id) ||
      @user.can_super_admin?
  end

  def destroy?
    (@user.can_org_admin? && @user.org.id == @record.org_id) ||
      @user.can_super_admin?
  end
end
