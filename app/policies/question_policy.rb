class QuestionPolicy < ApplicationPolicy
  attr_reader :user, :question

  def initialize(user, question)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @question = question
  end

  ##
  # Users can modify questions if:
  #  - They can modify templates
  #  - The template which they are modifying belongs to their org
  ##

  def admin_create?
    user.can_modify_templates?  &&  (question.section.phase.template.org_id == user.org_id)
  end

  def admin_update?
    user.can_modify_templates?  &&  (question.section.phase.template.org_id == user.org_id)
  end

  def admin_destroy?
    user.can_modify_templates?  &&  (question.section.phase.template.org_id == user.org_id)
  end

end