# frozen_string_literal: true

# Security rules for changing a ApiClient role on a plan from the Third party applications section
class ApiClientRolePolicy < ApplicationPolicy
  def create?
    @record.plan.administerable_by?(@user.id)
  end

  def update?
    @record.plan.administerable_by?(@user.id)
  end

  def destroy?
    @record.plan.administerable_by?(@user.id)
  end
end
