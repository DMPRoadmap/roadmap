# frozen_string_literal: true

module Api

  module V1

    module Madmp

      class PlansPolicy < ApplicationPolicy

        attr_reader :client, :plan

        class Scope

          attr_reader :client, :scope

          def initialize(client, scope)
            @client = client
            @scope = scope
          end

        end

        def initialize(client, plan)
          @client = client
          @plan = plan
        end

        def show?
          if client.is_a?(User)
            @plan.readable_by?(client.id)
          else
            false
          end
        end
      
        def rda_export?
          if client.is_a?(User)
            @plan.readable_by?(client.id)
          else
            false
          end
        end

      end

    end

  end

end
