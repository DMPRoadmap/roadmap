class NotificationPolicy < ApplicationPolicy
  def initialize(user, *_args)
    raise Pundit::NotAuthorizedError, _('must be logged in') unless user
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

  def edit?
    @user.can_super_admin?
  end

  def update?
    @user.can_super_admin?
  end

  def destroy?
    @user.can_super_admin?
  end
end
