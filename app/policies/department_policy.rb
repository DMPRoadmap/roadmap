# frozen_string_literal: true

<<<<<<< HEAD
class DepartmentPolicy < ApplicationPolicy

  attr_reader :user
  attr_reader :department

  def initialize(user, department)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    @user = user
    @department = department
=======
# Security rules for department editing
# Note the method names here correspond with controller actions
class DepartmentPolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of Department

  def index?
    (@user.can_org_admin? && @user.org.id == @department.org_id) ||
      @user.can_super_admin?
>>>>>>> upstream/master
  end

  def new?
    @user.can_org_admin? || @user.can_super_admin?
  end

  def create?
    @user.can_org_admin? || @user.can_super_admin?
  end

  def edit?
<<<<<<< HEAD
    (@user.can_org_admin? && @user.org.id == @department.org_id) ||
=======
    (@user.can_org_admin? && @user.org.id == @record.org_id) ||
>>>>>>> upstream/master
      @user.can_super_admin?
  end

  def update?
<<<<<<< HEAD
    (@user.can_org_admin? && @user.org.id == @department.org_id) ||
=======
    (@user.can_org_admin? && @user.org.id == @record.org_id) ||
>>>>>>> upstream/master
      @user.can_super_admin?
  end

  def destroy?
<<<<<<< HEAD
    (@user.can_org_admin? && @user.org.id == @department.org_id) ||
      @user.can_super_admin?
  end

=======
    (@user.can_org_admin? && @user.org.id == @record.org_id) ||
      @user.can_super_admin?
  end
>>>>>>> upstream/master
end
