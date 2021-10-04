# frozen_string_literal: true

# Security rules for viewing API V0 token permission types
# Note the method names here correspond with controller actions
class TokenPermissionTypePolicy < ApplicationPolicy
  attr_reader :user, :token_permission_type

  def initialize(user, token_permission_type)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless user

    super(user)
    @user = user
    @token_permission_type = token_permission_type
  end

  def index?
    user.can_use_api? && user.org.token_permission_types.count.positive?
  end
end
