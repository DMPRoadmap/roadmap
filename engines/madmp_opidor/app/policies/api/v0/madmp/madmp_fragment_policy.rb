# frozen_string_literal: true

module Api
  module V0
    module Madmp
      # Security rules for API V0 MadmpFragment endpoints
      class MadmpFragmentPolicy < ApplicationPolicy
        attr_reader :user, :madmp_fragment

        def show?
          plan = @fragment.plan
          plan.readable_by?(@user.id)
        end

        def update?
          plan = @fragment.plan
          plan.editable_by?(@user.id)
        end
      end
    end
  end
end
