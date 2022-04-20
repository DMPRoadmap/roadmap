# frozen_string_literal: true
<<<<<<< HEAD

class AnswerPolicy < ApplicationPolicy

  attr_reader :user
  attr_reader :answer

  def initialize(user, answer)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    @user = user
    @answer = answer
  end
=======

# Security rules for answering questions
# Note the method names here correspond with controller actions
class AnswerPolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of Answer
>>>>>>> upstream/master

  def create_or_update?
    # TODO: Remove the owner check after the Roles have been updated
    # is the plan editable by the user or the user is the owner of the plan
    @record.plan.editable_by?(@user.id) || @user == @record.plan.owner
  end
<<<<<<< HEAD

=======
>>>>>>> upstream/master
end
