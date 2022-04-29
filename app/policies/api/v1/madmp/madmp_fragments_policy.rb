# frozen_string_literal: true

module Api
  module V1
    module Madmp
      # Security rules for API V1 MadmpFragment endpoints
      class MadmpFragmentsPolicy < ApplicationPolicy
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
            plan = @fragment.plan
            plan.readable_by?(@client.id)
          else
            true
          end
        end

        def dmp_fragments?
          if client.is_a?(User)
            plan = @fragment.plan
            plan.readable_by?(@client.id)
          else
            true
          end
        end

        def update?
          if client.is_a?(User)
            plan = @fragment.plan
            plan.editable_by?(@client.id)
          else
            true
          end
        end
      end
    end
  end
end
