class TokenPermissionTypePolicy < ApplicationPolicy
  attr_reader :user, :token_permission_type

  def initialize(user, token_permission_type)
    @user = user
    @token_permission_type = token_permission_type
  end

  def index?
    user.can_use_api? && (user.organisation.token_permission_types.count > 0)
  end


end