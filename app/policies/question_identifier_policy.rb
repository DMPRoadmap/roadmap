# frozen_string_literal: true

# Note the method names here correspond with controller actions
class QuestionIdentifierPolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of QuestionIdentifier

  ##
  # The only action specifically on question_identifier is delete.
  # The policy on this is essentially the same as the policy
  # for editing questions i.e.
  #  - They can modify templates
  #  - The template which they are modifying belongs to their org
  ##
  def destroy?
    @user.can_modify_templates? &&
      (@record.question.section.phase.template.org_id == @user.org_id)
  end

  def list?
    @user.can_modify_templates? &&
      (@record.question.section.phase.template.org_id == @user.org_id)
  end
end
