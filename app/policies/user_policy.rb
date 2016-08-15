class UserPolicy
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

end