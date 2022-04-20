# frozen_string_literal: true

<<<<<<< HEAD
class PlanPolicy < ApplicationPolicy

  attr_reader :user
  attr_reader :plan

  def initialize(user, plan)
    raise Pundit::NotAuthorizedError, _("must be logged in") unless user

    unless plan || plan.publicly_visible?
      raise Pundit::NotAuthorizedError,
            _("are not authorized to view that plan")
    end
    @user = user
    @plan = plan
  end

  def show?
    @plan.readable_by?(@user.id)
  end

  def share?
    @plan.editable_by?(@user.id) ||
      (@user.can_org_admin? &&
       @user.org.plans.include?(@plan))
  end

  def export?
    @plan.readable_by?(@user.id)
  end

  def download?
    @plan.readable_by?(@user.id)
  end

  def edit?
    @plan.readable_by?(@user.id)
  end

  def update?
    @plan.editable_by?(@user.id)
  end

  def destroy?
    @plan.editable_by?(@user.id)
  end

  def status?
    @plan.readable_by?(@user.id)
  end

  def duplicate?
    @plan.editable_by?(@user.id)
  end

  def visibility?
    @plan.administerable_by?(@user.id)
  end

  def set_test?
    @plan.administerable_by?(@user.id)
  end

  def answer?
    @plan.readable_by?(@user.id)
  end

  def request_feedback?
    @plan.administerable_by?(@user.id)
  end

  def overview?
    @plan.readable_by?(@user.id)
  end

  def select_guidances_list?
    @plan.readable_by?(@user.id)
  end

  def update_guidances_list?
    @plan.editable_by?(@user.id)
=======
# Security rules for plans
# Note the method names here correspond with controller actions
class PlanPolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of Plan

  def index?
    @user.present?
  end

  def show?
    @record.readable_by?(@user.id)
  end

  def share?
    @record.editable_by?(@user.id) ||
      (@user.can_org_admin? &&
       @user.org.plans.include?(@record))
  end

  def export?
    @record.readable_by?(@user.id)
  end

  def download?
    @record.readable_by?(@user.id)
  end

  def edit?
    @record.readable_by?(@user.id)
  end

  def update?
    @record.editable_by?(@user.id)
  end

  def destroy?
    @record.editable_by?(@user.id)
  end

  def status?
    @record.readable_by?(@user.id)
  end

  def duplicate?
    @record.editable_by?(@user.id)
  end

  def visibility?
    @record.administerable_by?(@user.id)
  end

  def set_test?
    @record.administerable_by?(@user.id)
  end

  def answer?
    @record.readable_by?(@user.id)
  end

  def request_feedback?
    @record.administerable_by?(@user.id)
  end

  def overview?
    @record.readable_by?(@user.id)
  end

  def select_guidances_list?
    @record.readable_by?(@user.id)
  end

  def update_guidances_list?
    @record.editable_by?(@user.id)
  end

  def privately_visible?
    @user.present?
>>>>>>> upstream/master
  end

  def organisationally_or_publicly_visible?
    @user.present?
  end
end
