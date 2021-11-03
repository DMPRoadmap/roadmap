# frozen_string_literal: true

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
  end
end
