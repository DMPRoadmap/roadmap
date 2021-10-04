# frozen_string_literal: true

# Security rules for changing a Users role on a plan from the collaborators section
# Note the method names here correspond with controller actions
class RolePolicy < ApplicationPolicy
  attr_reader :user, :role

  def initialize(user, role)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless user

    super(user)
    @user = user
    @role = role
  end

  def create?
    @role.plan.administerable_by?(@user.id)
  end

  def update?
    @role.plan.administerable_by?(@user.id)
  end

  def destroy?
    @role.plan.administerable_by?(@user.id)
  end

  def deactivate?
    @role.user_id == @user.id
  end
end
