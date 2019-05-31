# frozen_string_literal: true

class DepartmentPolicy < ApplicationPolicy

  attr_reader :user
  attr_reader :department

  def initialize(user, department)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @department = department
  end

  def admin_new?
    puts "admin_new?: @department"
    puts @department
    @user.can_org_admin?
  end

  def admin_create?
    puts "admin_create?: @department"
    puts @department
    @user.can_org_admin?
  end

  def admin_edit?
    puts "admin_edit?: @department"
    puts @department
    # Only org_admins can edit their own org's departments
    @user.can_org_admin? && @user.org.id === @department.org_id
  end

  def admin_update?
    puts "admin_update?: @department"
    puts @department
    # Only org_admins can update their own org's departments
    @user.can_org_admin? && @user.org.id === @department.org_id
  end

  def admin_destroy?
    puts "admin_destroy?: @department"
    puts @department
    # Only org_admins can delete their own org's departments
    @user.can_org_admin? && @user.org.id === @department.org_id
  end

end
