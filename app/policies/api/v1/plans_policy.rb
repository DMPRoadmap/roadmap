# frozen_string_literal: true

module Api
  module V1
    # Security rules for API V1 Plan endpoints
    class PlansPolicy < ApplicationPolicy
      attr_reader :client, :plan

      # A helper method that takes the current client and returns the plans they
      # have acess to
      class Scope
        attr_reader :client, :scope

        def initialize(client, scope)
          super(client)
          @client = client
          @scope = scope
        end

        ## return the visible plans (via the API) to a given client
        # ALL can view: public
        # ApiClient can view: anything from the API client
        #                     anything belonging to their Org (if applicable)
        # User (non-admin) can view: any personal or organisationally_visible
        # User (admin) can view: all from users of their organisation
        def resolve
          ids = Plan.publicly_visible.pluck(:id)
          ids += plans_for_client if client.is_a?(ApiClient)
          ids += plans_for_user if client.is_a?(User)
          Plan.where(id: ids.uniq)
        end

        private

        def plans_for_client
          ids = client.plans.pluck(&:id)
          ids += client.org.plans.pluck(&:id) if client.org.present?
          ids
        end

        def plans_for_user
          ids = client.org.plans.organisationally_visible.pluck(:id)
          ids += client.plans.pluck(:id)
          ids += client.org.plans.pluck(:id) if client.can_org_admin?
          ids
        end
      end

      def initialize(client, plan)
        super(client)
        @client = client
        @plan = plan
      end
    end
  end
end
