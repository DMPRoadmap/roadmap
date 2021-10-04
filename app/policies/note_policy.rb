# frozen_string_literal: true

# Security rules for comments
# Note the method names here correspond with controller actions
class NotePolicy < ApplicationPolicy
  attr_reader :user, :note

  def initialize(user, note)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless user

    super(user)
    @user = user
    @note = note
  end

  def create?
    @note.answer.plan.commentable_by?(@user.id)
  end

  def update?
    Plan.find(@note.answer.plan_id).commentable_by?(@user.id) && @note.user_id == @user.id
  end

  def archive?
    Plan.find(@note.answer.plan_id).commentable_by?(@user.id)
  end
end
