class UserIdentifierPolicy < ApplicationPolicy
  attr_reader :user_identifier

  def initialize(user, users)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @users = users
  end

  def destroy?
    !user.nil?
  end

  class Scope < Scope
    def resolve
      scope.where(user_id: user.id)
    end
  end

end