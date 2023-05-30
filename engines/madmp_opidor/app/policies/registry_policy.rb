# frozen_string_literal: true

# Security rules for registry
class RegistryPolicy < ApplicationPolicy
  def index?
    @user.can_super_admin?
  end

  def show?
    @user.can_super_admin?
  end

  def new?
    @user.can_super_admin?
  end

  def create?
    @user.can_super_admin?
  end

  def edit?
    @user.can_super_admin?
  end

  def update?
    @user.can_super_admin?
  end

  def destroy?
    @user.can_super_admin?
  end

  def sort_values?
    @user.can_super_admin?
  end

  def download?
    @user.can_super_admin?
  end

  def upload?
    @user.can_super_admin?
  end
end
