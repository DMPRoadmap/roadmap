# frozen_string_literal: true

module SuperAdmin

  class OrgPolicy < ApplicationPolicy

    attr_reader :user, :org

    def initialize(user, org)
      raise Pundit::NotAuthorizedError, "must be logged in" unless user

      @user = user
      @org = org
    end

    def index?
      user.can_super_admin?
    end

    def new?
      user.can_super_admin?
    end

    def create?
      user.can_super_admin?
    end

    def destroy?
      user.can_super_admin?
    end

  end

end
