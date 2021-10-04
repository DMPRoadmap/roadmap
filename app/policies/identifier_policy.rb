# frozen_string_literal: true

# Security rules for un-associating a user from their Shib or ORCID
# Note the method names here correspond with controller actions
class IdentifierPolicy < ApplicationPolicy
  def initialize(user, users)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless user

    super(user)
    @user = user
    @users = users
  end

  def destroy?
    !user.nil?
  end

  # Returns the identifiers for the user
  class Scope < Scope
    def resolve
      scope.where(user_id: user.id)
    end
  end
end
