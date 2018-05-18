class RolePolicy < ApplicationPolicy
  attr_reader :user
  attr_reader :role

  def initialize(user, role)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
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
    @role.user_id = @user.id
  end
end