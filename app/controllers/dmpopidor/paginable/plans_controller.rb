# frozen_string_literal: true

module Dmpopidor

  module Paginable

    module PlansController

      # GET /paginable/plans/org_admin/:page
      # Renders only the plans with a visibility superior to privately
      def org_admin
        raise Pundit::NotAuthorizedError unless current_user.present? && current_user.can_org_admin?

        # check if current user if super_admin
        @super_admin = current_user.can_super_admin?
        @clicked_through = params[:click_through].present?
        plans = @super_admin ? Plan.all : current_user.org.org_admin_plans
        plans = plans.joins(:template, roles: [user: :org]).where(Role.creator_condition)

        paginable_renderise(
          partial: "org_admin",
          scope: plans,
          view_all: !current_user.can_super_admin?,
          query_params: { sort_field: "plans.updated_at", sort_direction: :desc },
          format: :json
        )
      end

      # CHANGES: New Visibility
      # /paginable/plans/administrator_visible/:page
      # Paginable for Administrator Private Visibility
      # Plans that are only visible by the owner of a plan, its collaborators and the org admin
      def administrator_visible
        raise Pundit::NotAuthorizedError unless ::Paginable::PlanPolicy.new(current_user).administrator_visible?

        paginable_renderise(
          partial: "administrator_visible",
          scope: Plan.active(current_user),
          query_params: { sort_field: "plans.updated_at", sort_direction: :desc },
          format: :json
        )
      end

      # CHANGES : Org Admin should access plan with administrator, organisation & public plan when editing a user
      # GET /paginable/plans/org_admin/:page
      def org_admin_other_user
        @user = User.find(params[:id])
        authorize @user
        unless current_user.present? && current_user.can_org_admin? && @user.present?
          raise Pundit::NotAuthorizedError
        end

        paginable_renderise(
          partial: "org_admin_other_user",
          scope: Plan.org_admin_visible(@user),
          query_params: { sort_field: "plans.updated_at", sort_direction: :desc }
        )
      end

    end

  end

end
