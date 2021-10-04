# frozen_string_literal: true

module Paginable
  # Security rules for plan tables
  class PlanPolicy < ApplicationPolicy
    def initialize(user)
      super(user)
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
