# frozen_string_literal: true

# Security rules for changing a Users role on a plan from the collaborators section
# Note the method names here correspond with controller actions
class RolePolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of Role

  def create?
    @record.plan.administerable_by?(@user.id)
  end

  def update?
    @record.plan.administerable_by?(@user.id)
  end

  def destroy?
    @record.plan.administerable_by?(@user.id)
  end

  def deactivate?
    @record.user_id == @user.id
  end
end
