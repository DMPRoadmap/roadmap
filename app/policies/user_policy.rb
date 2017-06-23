class UserPolicy < ApplicationPolicy
  attr_reader :user

  def initialize(user, users)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @users = users
  end

  def admin_index?
    @user.can_grant_permissions?
  end

  def admin_grant_permissions?
    @user.can_grant_permissions? && (@users.org_id == @user.org_id)
  end

  def admin_update_permissions?
    @user.can_grant_permissions?  && (@users.org_id == @user.org_id)
  end

  class Scope < Scope
    def resolve
      scope.where(org_id: user.org_id)
    end
  end

end