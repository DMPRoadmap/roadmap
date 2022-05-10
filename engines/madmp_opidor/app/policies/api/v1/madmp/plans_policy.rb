# frozen_string_literal: true

module Api
  module V1
    module Madmp
      # Security rules for API V1 Plan endpoints
      class PlansPolicy < ApplicationPolicy
        attr_reader :client, :plan

        # A helper method that takes the current client and returns the plans they
        # have acess to
        class Scope
          attr_reader :client, :scope

          def initialize(client, scope)
            @client = client
            @scope = scope
          end
        end

        def show?
          if client.is_a?(User)
            @plan.readable_by?(client.id)
          else
            true
          end
        end

        def rda_export?
          if client.is_a?(User)
            @plan.readable_by?(client.id)
          else
            true
          end
        end
      end
    end
  end
end
