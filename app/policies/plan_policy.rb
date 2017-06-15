class PlanPolicy < ApplicationPolicy
  attr_reader :user
  attr_reader :plan

  def initialize(user, plan)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @plan = plan
  end

  def show?
    @plan.readable_by?(@user.id)
  end

  def edit?
    @plan.readable_by?(@user.id)
  end

  def update_guidance_choices?
    @plan.editable_by?(@user.id)
  end

  def share?
    @plan.readable_by?(@user.id)
  end

  def export?
    @plan.readable_by?(@user.id)
  end

  def show_export?
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

  def possible_templates?
    @plan.id.nil?
  end

  def duplicate?
    @plan.editable_by?(@user.id)
  end
  
  def visibility?
    @plan.administerable_by?(@user.id)
  end

# TODO: These routes are no lonmger used
=begin
  def section_answers?
    @plan.readable_by?(@user.id)
  end

  def locked?
    @plan.readable_by?(@user.id)
  end

  def delete_recent_locks?
    @plan.editable_by?(@user.id)
  end

  def unlock_all_sections?
    @plan.editable_by?(@user.id)
  end

  def lock_section?
    @plan.editable_by?(@user.id)
  end

  def unlock_section?
    @plan.editable_by?(@user.id)
  end
=end

  def answer?
    @plan.readable_by?(@user.id)
  end

end
