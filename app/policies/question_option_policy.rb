# frozen_string_literal: true

# Security rules for options of multi select questions
# Note the method names here correspond with controller actions
class QuestionOptionPolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of QuestionOption

  ##
  # The only action specifically on question_options is delete.
  # The policy on this is essentially the same as the policy
  # for editing questions i.e.
  #  - They can modify templates
  #  - The template which they are modifying belongs to their org
  ##
  def destroy?
    @user.can_modify_templates? &&
      (@record.question.section.phase.template.org_id == @user.org_id)
  end
end
