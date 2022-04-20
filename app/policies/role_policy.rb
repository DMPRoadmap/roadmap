# frozen_string_literal: true
<<<<<<< HEAD

class RolePolicy < ApplicationPolicy

  attr_reader :user
  attr_reader :role

  def initialize(user, role)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    @user = user
    @role = role
  end
=======

# Security rules for changing a Users role on a plan from the collaborators section
# Note the method names here correspond with controller actions
class RolePolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of Role
>>>>>>> upstream/master

  def create?
    @record.plan.administerable_by?(@user.id)
  end

  def update?
    @record.plan.administerable_by?(@user.id)
  end

  def destroy?
<<<<<<< HEAD
    @role.plan.administerable_by?(@user.id)
  end

  def deactivate?
    @role.user_id == @user.id
  end

=======
    @record.plan.administerable_by?(@user.id)
  end

  def deactivate?
    @record.user_id == @user.id
  end
>>>>>>> upstream/master
end
