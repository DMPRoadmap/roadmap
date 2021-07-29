# frozen_string_literal: true

module Api

  module V1

    module Madmp

      class MadmpFragmentsPolicy < ApplicationPolicy

        attr_reader :client, :plan

        class Scope

          attr_reader :client, :scope

          def initialize(client, scope)
            @client = client
            @scope = scope
          end

        end

        def initialize(client, madmp_fragment)
          @client = client
          @fragment = madmp_fragment
        end

        def show?
          if client.is_a?(User)
            plan = @fragment.plan
            plan.readable_by?(@client.id)
          else
            false
          end
        end

        def dmp_fragments?
          if client.is_a?(User)
            plan = @fragment.plan
            plan.readable_by?(@client.id)
          else
            false
          end
        end
      
        def update?
          if client.is_a?(User)
            plan = @fragment.plan
            plan.editable_by?(@client.id)
          else
            false
          end
        end

      end

    end

  end

end
