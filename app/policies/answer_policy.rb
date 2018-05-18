class AnswerPolicy < ApplicationPolicy
  attr_reader :user
  attr_reader :answer

  def initialize(user, answer)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @answer = answer
  end

  def create_or_update?
    # TODO: Remove the owner check after the Roles have been updated
    # is the plan editable by the user or the user is the owner of the plan
    @answer.plan.editable_by?(@user.id) || @user == @answer.plan.owner
  end

end