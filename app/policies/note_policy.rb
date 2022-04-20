# frozen_string_literal: true
<<<<<<< HEAD

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
    Plan.find(@note.answer.plan_id).commentable_by?(@user.id) && @note.user_id == @user.id
  end

  def archive?
    Plan.find(@note.answer.plan_id).commentable_by?(@user.id)
=======

# Security rules for comments
# Note the method names here correspond with controller actions
class NotePolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of Note

  def create?
    @record.answer.plan.commentable_by?(@user.id)
  end

  def update?
    Plan.find(@record.answer.plan_id).commentable_by?(@user.id) && @record.user_id == @user.id
  end

  def archive?
    Plan.find(@record.answer.plan_id).commentable_by?(@user.id)
>>>>>>> upstream/master
  end
end
