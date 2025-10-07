# frozen_string_literal: true

# Security rules for viewing API V0 token permission types
# Note the method names here correspond with controller actions
class TokenPermissionTypePolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user

  def index?
    @user.can_use_api? && @user.org.token_permission_types.any?
  end
end
