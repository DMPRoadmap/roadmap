# frozen_string_literal: true

module Api
  module V0
    module Madmp
      # Security rules for API V0 Plans endpoints
      class PlanPolicy < ApplicationPolicy
        attr_reader :user, :plan

        def show?
          @plan.readable_by?(@user.id)
        end

        def rda_export?
          @plan.readable_by?(@user.id)
        end
      end
    end
  end
end
