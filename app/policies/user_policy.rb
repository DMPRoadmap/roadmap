class UserPolicy < ApplicationPolicy
  attr_reader :user

  def initialize(user, users)
    @user = user
  end

  def admin_index?
    user.can_use_api? && user.can_grant_permissions?
  end

  def admin_api_update?
    user.can_use_api? && user.can_grant_permissions?
  end

  class Scope < Scope
    def resolve
      scope.where(organisation_id: user.organisation_id)
    end
  end

end