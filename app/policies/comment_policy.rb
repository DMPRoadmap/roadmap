class CommentPolicy < ApplicationPolicy
  attr_reader :user
  attr_reader :comment

  def initialize(user, comment)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @comment = comment
  end

  def create?
    Plan.find(@comment.plan_id).readable_by(@user.id)
  end

  def update?
    Plan.find(@comment.plan_id).readable_by(@user.id)
  end

  def archive?
    Plan.find(@comment.plan_id).readable_by(@user.id)
  end

end