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

        attr_reader :client, :scope

        def initialize(client, resource_owner, scopes)
          @client = client
          @resource_owner = resource_owner
          @scopes = scopes
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
          # Only return publicly visible Plans if the caller did not request Plans for a specific User
          return plans_for_user(user: @resource_owner, complete: true, mine: true) if @resource_owner.present?

          plans = Plan.publicly_visible
          # If the caller is an ApiClient return the Client's Plans
          return (plans += plans_for_api_client).flatten.compact.uniq if @client.is_a?(ApiClient)

          # Otherwise return the User's Plans
          plans += plans_for_org_admin + plans_for_user(user: @client)
          plans.flatten.compact.uniq
        end

        private

        def validate_scopes(required_scopes:)
          return true if @client.trusted?

          required_scopes.blank? || required_scopes.any? { |scope| required_scopes.include?(scope.to_s) }
        end

        # Fetch all of the User's Plans
        def plans_for_user(user:, complete: false, mine: false)
          return [] unless validate_scopes(required_scopes: %w[read_your_dmps])

          plans = user.plans.reject { |plan| plan.is_test? }
          plans = complete ? plans.select { |plan| plan.complete? } : plans
          plans += user.org.plans.organisationally_visible unless mine
          plans.to_a.flatten.compact.uniq
        end

        # Fetch all of the Plans that belong to the Admin's Org
        def plans_for_org_admin
          return [] unless validate_scopes(required_scopes: %w[read_your_dmps])

          @client.can_org_admin? ? @client.org.plans.reject { |plan| plan.is_test? } : []
        end

        # Fetch all of the Plans created by the ApiClient or any that belong to its associated Org
        def plans_for_api_client
          return [] unless validate_scopes(required_scopes: %w[read_public_dmps])

          plans = @client.plans
          plans += @client.org.plans if @client.org.present?
          plans.to_a.flatten.compact.uniq
        end

      end

    end

  end

end
