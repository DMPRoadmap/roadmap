# frozen_string_literal: true

# Security rules for editing Annotations: Example Answers, Question level guidance
# Note the method names here correspond with controller actions
class AnnotationPolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of Annotation

  def create?
    question = Question.find_by(id: @record.question_id)
    return @user.can_modify_templates? && question.template.org_id == @user.org_id if question.present?

    false
  end

  def update?
    @user.can_modify_templates? && @record.template.org_id == @user.org_id
  end

  def destroy?
    update?
  end
end
