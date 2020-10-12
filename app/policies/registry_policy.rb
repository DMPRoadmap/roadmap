class RegistryPolicy < ApplicationPolicy
  def initialize(user, *args)
    raise Pundit::NotAuthorizedError, _("must be logged in") unless user
    @user = user
  end

  def index?
    @user.can_super_admin?
  end

  def new?
    @user.can_super_admin?
  end

  def create?
    @user.can_super_admin?
  end
end
