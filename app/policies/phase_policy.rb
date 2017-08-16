class PhasePolicy < ApplicationPolicy
  attr_reader :user, :phase

  def initialize(user, phase)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @phase = phase
  end

  ##
  # Org-admin side
  # Users can modify phases if:
  #  - They can modify templates
  #  - The template which they are modifying belongs to their org

  def admin_show?
    user.can_modify_templates?  && (phase.template.org_id == user.org_id)
  end

  def admin_preview?
    user.can_modify_templates?  &&  (phase.template.org_id == user.org_id)
  end

  def admin_update?
    user.can_modify_templates?  &&  (phase.template.org_id == user.org_id)
  end

  def admin_add?
    user.can_modify_templates?  && (phase.template.org_id == user.org_id)
  end

  def admin_create?
    user.can_modify_templates?  &&  (phase.template.org_id == user.org_id)
  end

  def admin_destroy?
    user.can_modify_templates?  &&  (phase.template.org_id == user.org_id)
  end

end