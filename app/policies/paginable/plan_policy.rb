module Paginable
  class PlanPolicy < ApplicationPolicy
    def initialize(user)
      @user = user
    end
    def privately_visible?
      @user.is_a?(User)
    end

    def organisationally_or_publicly_visible?
      @user.is_a?(User)
    end
  end
end