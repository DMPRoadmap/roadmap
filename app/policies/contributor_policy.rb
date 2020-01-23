# frozen_string_literal: true

class ContributorPolicy < ApplicationPolicy

  attr_reader :user
  attr_reader :plan

  def initialize(user, plan)
    raise Pundit::NotAuthorizedError, _("must be logged in") unless user
    raise Pundit::NotAuthorizedError,
          _("are not authorized to edit that plan") unless plan
    @user = user
    @plan = plan
  end

  # GET /plans/:plan_id/contributors
  def index?
    @plan.readable_by?(@user.id)
  end

  # GET /plans/:plan_id/contributors/:id
  def show?
    @plan.readable_by?(@user.id)
  end

  # GET /plans/:plan_id/contributors/new
  def new?
    @plan.administerable_by?(@user.id)
  end

  # GET /plans/:plan_id/contributors/:id/edit
  def edit?
    @plan.administerable_by?(@user.id)
  end

  # POST /plans/:plan_id/contributors
  def create?
    @plan.administerable_by?(@user.id)
  end

  # PUT /plans/:plan_id/contributors/:id
  def update?
    @plan.administerable_by?(@user.id)
  end

  # DELETE /plans/:plan_id/contributors/:id
  def destroy?
    @plan.administerable_by?(@user.id)
  end

end
