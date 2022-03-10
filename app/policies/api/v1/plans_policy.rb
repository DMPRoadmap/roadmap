# frozen_string_literal: true

module Api
  module V1
    # Security rules for API V1 Plan endpoints
    class PlansPolicy < ApplicationPolicy
      # NOTE: @user is either a User or an ApiClient

      # A helper method that takes the current client and returns the plans they
      # have acess to
      class Scope
        attr_reader :client, :scope

        def initialize(client, scope)
          @client = client
          @scope = scope
        end

        ## return the visible plans (via the API) to a given client
        # ALL can view: public
        # ApiClient can view: anything from the API client
        #                     anything belonging to their Org (if applicable)
        # User (non-admin) can view: any personal or organisationally_visible
        # User (admin) can view: all from users of their organisation
        # rubocop:disable Metrics/AbcSize
        def resolve
          ids = Plan.publicly_visible.pluck(:id)
          # rubocop:disable Style/CaseLikeIf
          if client.is_a?(ApiClient)
            ids += client.subscriptions.pluck(&:plan_id)
            ids += client.user.org.plans.pluck(&:id) if client.user.present? && client.user.org.present?
          elsif client.is_a?(User)
            ids += client.org.plans.organisationally_visible.pluck(:id)
            ids += client.plans.pluck(:id)
            ids += client.org.plans.pluck(:id) if client.can_org_admin?
          end
          # rubocop:enable Style/CaseLikeIf
          Plan.where(id: ids.uniq)
        end
        # rubocop:enable Metrics/AbcSize

        private

        def plans_for_client
          ids = @user.plans.pluck(&:id)
          ids += @user.org.plans.pluck(&:id) if @user.org.present?
          ids
        end

        def plans_for_user
          ids = @user.org.plans.organisationally_visible.pluck(:id)
          ids += @user.plans.pluck(:id)
          ids += @user.org.plans.pluck(:id) if @user.can_org_admin?
          ids
        end
      end
    end
  end
end
