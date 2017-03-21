class Settings::PlanPolicy < ApplicationPolicy

  attr_reader :user
  attr_reader :plan

  def initialize(user, plan)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @plan = plan
  end

  def show?
    @plan.readable_by(@user.id)
  end

  def update?
    @plan.editable_by(@user.id)
  end

end