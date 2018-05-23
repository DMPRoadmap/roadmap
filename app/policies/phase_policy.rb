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

  def show?
    user.can_modify_templates?  && (phase.template.org_id == user.org_id)
  end

  def preview?
    user.can_modify_templates?  &&  (phase.template.org_id == user.org_id)
  end

  def update?
    user.can_modify_templates?  &&  (phase.template.org_id == user.org_id)
  end

  def new?
    user.can_modify_templates?  && (phase.template.org_id == user.org_id)
  end

  def create?
    user.can_modify_templates?  &&  (phase.template.org_id == user.org_id)
  end

  def destroy?
    user.can_modify_templates?  &&  (phase.template.org_id == user.org_id)
  end

end