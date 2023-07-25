# frozen_string_literal: true

module Api
  module V2
    # Base policy for Plan endpoints
    class PlansPolicy < ApplicationPolicy
      attr_reader :client, :resource_owner

      def initialize(client, resource_owner, plan)
        @resource_owner = resource_owner
        @client = client
        super(client, plan)
      end

      # Scope to limit which plans the ApiClient has access to based on their perms
      class Scope
        attr_reader :client, :resource_owner

        def initialize(client, resource_owner, result_scope)
          @resource_owner = resource_owner
          @client = client
          @scope = result_scope
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
        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def resolve
          return plans_for_public if @scope == 'public'

          # If this is a :trusted ApiClient then return all plans
          return Plan.where.not(visibility: Plan.visibilities[:is_test]) if @client.trusted?

          # If the caller specified that they want both public and user plans
          public_plans = @scope == 'both' ? plans_for_public : []

          # If the resource_owner is present then return their specific Plans
          plans = plans_for_user(user: @resource_owner, complete: true, mine: true) if @resource_owner.present?
          return (plans + public_plans).flatten.uniq if @resource_owner.present?

          # If the Client is an Org Admin then get all of the Org's plans
          plans = plans_for_org_admin + plans_for_user(user: @client.user) if @client.user&.can_org_admin? &&
                                                                              @resource_owner.nil?
          return (plans + public_plans).flatten.uniq if plans.present?

          # There is no resource owner so this isn't an authorization_code flow so return the Client's plans
          plans_for_user(user: @client.user, complete: false)
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

        private

        def plans_for_public
          Plan.publicly_visible.order(updated_at: :desc)
        end

        # Fetch all of the User's Plans
        def plans_for_user(user:, complete: false, mine: false)
          plans = Plan.active(user)
          plans = plans.select { |plan| plan.complete? && !plan.is_test? } if complete
          plans += user.org.plans.organisationally_visible unless mine
          plans.to_a.flatten.compact.uniq
        end

        # Fetch all of the Plans that belong to the Admin's Org
        def plans_for_org_admin
          # TODO: Update this to use the new method created by @john_pinto
          @client.user.can_org_admin? ? Plan.where(org: @client.user.org).reject(&:is_test?) : []
        end
      end
    end
  end
end
