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
          ids = Plan.publicly_visible.pluck(:id)
          ids += plans_for_client if @user.is_a?(ApiClient)
          ids += plans_for_user if @user.is_a?(User)
          Plan.where(id: ids.uniq)
        end

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
