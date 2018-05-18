class NotePolicy < ApplicationPolicy
  attr_reader :user
  attr_reader :note

  def initialize(user, note)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @note = note
  end

  def create?
    @note.answer.plan.commentable_by?(@user.id)
  end

  def update?
    Plan.find(@note.answer.plan_id).commentable_by?(@user.id)
  end

  def archive?
    Plan.find(@note.answer.plan_id).commentable_by?(@user.id)
  end

end
