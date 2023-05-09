# frozen_string_literal: true

# Security rules for madmpschemas
class MadmpSchemaPolicy < ApplicationPolicy
  def index?
    @user.can_super_admin?
  end

  def show?
    true
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
end
