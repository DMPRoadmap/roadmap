module Paginable
  class TemplatePolicy < ApplicationPolicy
    def initialize(user)
      @user = user
    end
    def all?
      @user.is_a?(User) && @user.can_super_admin?
    end

    def funders?
      @user.is_a?(User) && @user.can_org_admin?
    end
    
    def orgs?
      @user.is_a?(User) && @user.can_org_admin?
    end
  end
end