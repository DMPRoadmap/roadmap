# frozen_string_literal: true
<<<<<<< HEAD

class Settings::PlanPolicy < ApplicationPolicy
=======
>>>>>>> upstream/master

module Settings
  # Security rules plan export settings
  class PlanPolicy < ApplicationPolicy
    # NOTE: @user is the signed_in_user and @record is an instance of Plan

<<<<<<< HEAD
  def initialize(user, plan)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    @user = user
    @plan = plan
  end

  def show?
    @plan.readable_by(@user.id)
  end
=======
    def show?
      @record.readable_by(@user.id)
    end
>>>>>>> upstream/master

    def update?
      @record.editable_by(@user.id)
    end
  end
<<<<<<< HEAD

=======
>>>>>>> upstream/master
end
