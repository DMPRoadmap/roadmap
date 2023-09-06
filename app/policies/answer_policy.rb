# frozen_string_literal: true

# Security rules for answering questions
# Note the method names here correspond with controller actions
class AnswerPolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of Answer

  def create_or_update?
    # TODO: Remove the owner check after the Roles have been updated
    # is the plan editable by the user or the user is the owner of the plan
    @record.plan.editable_by?(@user.id) || @user == @record.plan.owner
  end

  def notes?
    @record.plan.readable_by?(@user.id)
  end
end
