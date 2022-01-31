# frozen_string_literal: true

# Security rules for un-associating a user from their Shib or ORCID
# Note the method names here correspond with controller actions
class IdentifierPolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user

  def destroy?
    !@user.nil?
  end

  # Returns the identifiers for the user
  class Scope < Scope
    def resolve
      @scope.where(user_id: @user.id)
    end
  end
end
