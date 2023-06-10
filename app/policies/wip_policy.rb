# frozen_string_literal: true

# Base policy for Plan endpoints
class WipPolicy < ApplicationPolicy
  attr_reader :user, :wip

  def index?
    @user.can_org_admin?
  end

  def new?
    @user.can_org_admin?
  end

  def funders?
    @user.can_org_admin?
  end

  def overview?
    @user.can_org_admin?
  end

  def create?
    @user.can_org_admin?
  end

  def update?
    @user.can_org_admin? && @record.user_id == @user.id
  end

  def delete?
    @user.can_org_admin? && @record.user_id == @user.id
  end

  class Scope
    attr_reader :user, :wip

    def initialize(user, wip)
      raise Pundit::NotAuthorizedError, 'must be logged in' unless user

      @user = user
      @wip = wip
    end

    def resolve
      Wip.where(user_id: @user.id)
    end
  end
end
