# frozen_string_literal: true

# Security rules for plans
# Note the method names here correspond with controller actions
class PlanPolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of Plan

  def show?
    @record.readable_by?(@user.id)
  end

  def publish?
    @plan.editable_by?(@user.id) ||
      (@user.can_org_admin? &&
       @user.org.plans.include?(@plan))
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

  def mint?
    @plan.owner == @user || @user.can_super_admin?
  end

  def add_orcid_work?
    @plan.administerable_by?(@user.id)
  end
end
