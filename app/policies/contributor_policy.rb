# frozen_string_literal: true

class ContributorPolicy < ApplicationPolicy

  attr_reader :user, :plan

  def initialize(user, plan)
    raise Pundit::NotAuthorizedError, _("must be logged in") unless user
    raise Pundit::NotAuthorizedError, _("are not authorized to view that plan") unless plan.present?

    @user = user
    @plan = plan
  end

  def index?
    @plan.readable_by?(@user.id)
  end

  def new?
    @plan.administerable_by?(@user.id)
  end

  def edit?
    @plan.administerable_by?(@user.id)
  end

  def create?
    @plan.administerable_by?(@user.id)
  end

  def update?
    @plan.administerable_by?(@user.id)
  end

  def destroy?
    @plan.administerable_by?(@user.id)
  end

end
