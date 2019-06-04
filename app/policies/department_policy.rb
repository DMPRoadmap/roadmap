# frozen_string_literal: true

class DepartmentPolicy < ApplicationPolicy

  attr_reader :user
  attr_reader :department

  def initialize(user, department)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @department = department
  end

  def new?
    @user.can_org_admin?
  end

  def create?
    @user.can_org_admin?
  end

  def edit?
    # Only org_admins can edit their own org's departments
    @user.can_org_admin? && @user.org.id === @department.org_id
  end

  def update?
    # Only org_admins can update their own org's departments
    @user.can_org_admin? && @user.org.id === @department.org_id
  end

  def destroy?
    # Only org_admins can delete their own org's departments
    @user.can_org_admin? && @user.org.id === @department.org_id
  end

end
