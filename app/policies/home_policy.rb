class UserPolicy < ApplicationPolicy
  attr_reader :user

  def initialize(user, users)
    @user = user
    @users = users
  end

  def index?
    true
  end

  class Scope < Scope
    def resolve
      scope.where(organisation_id: user.organisation_id)
    end
  end

end