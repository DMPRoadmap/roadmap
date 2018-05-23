class AnnotationPolicy < ApplicationPolicy
  attr_reader :user, :annotation

  def initialize(user, annotation)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @annotation = annotation
  end

  def create?
    question = Question.find_by(id: @annotation.question_id)
    if question.present?
      return @user.can_modify_templates? && question.template.org_id == @user.org_id
    end
    return false
  end

  def update?
    @user.can_modify_templates? && annotation.template.org_id == @user.org_id
  end

  def destroy?
    update?
  end
end