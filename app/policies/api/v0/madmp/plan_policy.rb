# frozen_string_literal: true

class Api::V0::Madmp::PlanPolicy < ApplicationPolicy
  attr_reader :user, :plan

  def initialize(user, plan)
    raise Pundit::NotAuthorizedError, _('must be logged in') unless user

    @user = user
    @plan = plan
  end

  def show?
    @plan.readable_by?(@user.id)
  end

  def rda_export?
    @plan.readable_by?(@user.id)
  end
end
