# frozen_string_literal: true

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

  def publish?
    # TODO: The last portion of this check is for our soft-launch of DOI minting!
    @plan.editable_by?(@user.id) ||
      (@user.can_org_admin? &&
       @user.org.plans.include?(@plan)) ||
      (@user.org&.allow_doi? && @user.can_org_admin?)
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
  end

  def mint?
    @plan.administerable_by?(@user.id) || @user.can_super_admin?
  end

end
