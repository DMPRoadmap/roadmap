# frozen_string_literal: true

<<<<<<< HEAD
class QuestionOptionPolicy < ApplicationPolicy

  attr_reader :user, :question_option

  def initialize(user, question_option)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    @user = user
    @question_option = question_option
  end
=======
# Security rules for options of multi select questions
# Note the method names here correspond with controller actions
class QuestionOptionPolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of QuestionOption
>>>>>>> upstream/master

  ##
  # The only action specifically on question_options is delete.
  # The policy on this is essentially the same as the policy
  # for editing questions i.e.
  #  - They can modify templates
  #  - The template which they are modifying belongs to their org
  ##
<<<<<<< HEAD

  def destroy?
    user.can_modify_templates? &&
      (question_option.question.section.phase.template.org_id == user.org_id)
  end

=======
  def destroy?
    @user.can_modify_templates? &&
      (@record.question.section.phase.template.org_id == @user.org_id)
  end
>>>>>>> upstream/master
end
