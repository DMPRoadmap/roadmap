# frozen_string_literal: true

module Api

  module V2

    class PlansPolicy < ApplicationPolicy

      attr_reader :client, :plan

      def initialize(client, resource_owner, plan)
        @client = client
        @resource_owner = resource_owner
        @plan = plan
      end

      class Scope

        attr_reader :client

        def initialize(client, resource_owner)
          @client = client
          @resource_owner = resource_owner
        end

        ## Return the visible plans (via the API) to a given client depending on the context
        #
        # If @resource_owner is present then this is a request on behalf of a User
        #   - return the Plans specific for the User (resource_owner)
        #
        # If no @resource_owner is present then this is a 'direct' request so adhere to the following rules:
        #   - ALL can view: public
        #   - when @client is an ApiClient can view:
        #       - anything created by the API client
        #       - anything belonging to the ApiClient's Org (if applicable - api_clients.org_id)
        #   - when @client is a User can view:
        #       - (when a non-admin) any privately_visible or organisationally_visible Plans
        #       - (when an admin) all Plans from users of their organisation
        #
        def resolve
          # If the resource_owner is present then return their specific Plans
          return plans_for_user(user: @resource_owner, complete: true, mine: true) if @resource_owner.present?

          # If the Client is a User then the person Auth-ed via api_token so return their Plans
          return plans_for_org_admin + plans_for_user(user: @client) if @client.is_a?(User)

          # If this is a :trusted ApiClient then return all plans
          return Plan.where.not(visibility: Plan.visibilities[:is_test]) if @client.trusted?

          # If the caller is an ApiClient return all of the public plans and any they subscribe to
          plans = Plan.publicly_visible
          (plans += plans_for_api_client).flatten.compact.uniq
        end

        private

        # Fetch all of the User's Plans
        def plans_for_user(user:, complete: false, mine: false)
          plans = user.plans.reject { |plan| plan.is_test? }
          plans = complete ? plans.select { |plan| plan.complete? } : plans
          plans += user.org.plans.organisationally_visible unless mine
          plans.to_a.flatten.compact.uniq
        end

        # Fetch all of the Plans that belong to the Admin's Org
        def plans_for_org_admin
          @client.can_org_admin? ? @client.org.plans.reject { |plan| plan.is_test? } : []
        end

        # Fetch all of the Plans the ApiClient subscribes to or any that belong to its associated Org
        def plans_for_api_client
          plans = @client.subscriptions.map(&:plan)
          plans += @client.org.plans if @client.org.present?
          plans.to_a.flatten.compact.uniq
        end

      end

    end

  end

end
