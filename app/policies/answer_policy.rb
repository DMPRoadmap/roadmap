class AnswerPolicy < ApplicationPolicy
  attr_reader :user
  attr_reader :answer

  def initialize(user, answer)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @answer = answer
  end

  def create?
    # is the plan editable by the user, and is the user_id that of the user
    @answer.plan.editable_by(@user.id) && (@answer.user_id == @user.id)
  end

end