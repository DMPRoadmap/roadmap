# frozen_string_literal: true
<<<<<<< HEAD

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
=======

# Security rules for editing Annotations: Example Answers, Question level guidance
# Note the method names here correspond with controller actions
class AnnotationPolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of Annotation

  def create?
    question = Question.find_by(id: @record.question_id)
    return @user.can_modify_templates? && question.template.org_id == @user.org_id if question.present?
>>>>>>> upstream/master

    false
  end

  def update?
<<<<<<< HEAD
    @user.can_modify_templates? && annotation.template.org_id == @user.org_id
=======
    @user.can_modify_templates? && @record.template.org_id == @user.org_id
>>>>>>> upstream/master
  end

  def destroy?
    update?
  end
<<<<<<< HEAD

=======
>>>>>>> upstream/master
end
