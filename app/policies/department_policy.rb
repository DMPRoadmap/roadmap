# frozen_string_literal: true

# Security rules for department editing
# Note the method names here correspond with controller actions
class DepartmentPolicy < ApplicationPolicy
  attr_reader :user, :department

  def initialize(user, department)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless user

    super(user)
    @user = user
    @department = department
  end

  def new?
    @user.can_org_admin? || @user.can_super_admin?
  end

  def create?
    @user.can_org_admin? || @user.can_super_admin?
  end

  def edit?
    (@user.can_org_admin? && @user.org.id == @department.org_id) ||
      @user.can_super_admin?
  end

  def update?
    (@user.can_org_admin? && @user.org.id == @department.org_id) ||
      @user.can_super_admin?
  end

  def destroy?
    (@user.can_org_admin? && @user.org.id == @department.org_id) ||
      @user.can_super_admin?
  end
end
