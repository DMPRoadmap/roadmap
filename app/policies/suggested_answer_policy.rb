class SuggestedAnswerPolicy < ApplicationPolicy
  attr_reader :user, :suggested_answer

  def initialize(user, suggested_answer)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @suggested_answer = suggested_answer
  end

  ##
  # Users can modify suggested answers if:
  #  - They can modify templates
  #  - The template which they are modifying belongs to their org
  ##

  def admin_create?
    user.can_modify_templates?  &&  (suggested_answer.question.section.phase.template.org_id == user.org_id)
  end

  def admin_update?
    user.can_modify_templates?  &&  (suggested_answer.question.section.phase.template.org_id == user.org_id)
  end

  def admin_destroy?
    user.can_modify_templates?  &&  (suggested_answer.question.section.phase.template.org_id == user.org_id)
  end

end