# frozen_string_literal: true

module Api
  module V1
    # Security rules for API V1 Plan endpoints
    class PlansPolicy < ApplicationPolicy
      # NOTE: @user is either a User or an ApiClient

      # A helper method that takes the current client and returns the plans they
      # have acess to
      class Scope
        ## return the visible plans (via the API) to a given client
        # ALL can view: public
        # ApiClient can view: anything from the API client
        #                     anything belonging to their Org (if applicable)
        # User (non-admin) can view: any personal or organisationally_visible
        # User (admin) can view: all from users of their organisation
        def resolve
          ids = @user.is_a?(ApiClient) ? plans_for_client : plans_for_user
          Plan.where(id: ids.uniq)
        end

        private

        def plans_for_client
          return [] unless @user.present?

          ids = @user.plans.pluck(:id)
          ids += @user.org.plans.pluck(:id) if @user.org.present?
          ids.uniq
        end

        def plans_for_user
          return [] unless @user.present?

          ids = @user.org.plans.organisationally_visible.pluck(:id)
          ids += @user.plans.pluck(:id)
          ids += @user.org.plans.pluck(:id) if @user.can_org_admin?
          ids.uniq
        end

        def initialize(client, plan)
          super()
          @user = client
          @plan = plan
        end
      end
    end
  end
end
