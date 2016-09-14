class AnswerPolicy < ApplicationPolicy
  attr_reader :user

  def initialize(user, answer)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @answer = answer
  end

  def create?
    @answer.plan.editable_by(@user.id)
  end

end