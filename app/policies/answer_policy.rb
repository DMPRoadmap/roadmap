# frozen_string_literal: true

# Security rules for answering questions
# Note the method names here correspond with controller actions
class AnswerPolicy < ApplicationPolicy
  attr_reader :user, :answer

  def initialize(user, answer)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless user

    super(user)
    @user = user
    @answer = answer
  end

  def create_or_update?
    # TODO: Remove the owner check after the Roles have been updated
    # is the plan editable by the user or the user is the owner of the plan
    @answer.plan.editable_by?(@user.id) || @user == @answer.plan.owner
  end
end
