# frozen_string_literal: true

module Dmpopidor
  module Paginable
    module PlansController
      # CHANGES: New Visibility
      # /paginable/plans/administrator_visible/:page
      # Paginable for Administrator Private Visibility
      # Plans that are only visible by the owner of a plan, its collaborators and the org admin
      def administrator_visible
        raise Pundit::NotAuthorizedError unless Paginable::PlanPolicy.new(current_user).administrator_visible?

        paginable_renderise(
          partial: 'administrator_visible',
          scope: ::Plan.org_admin_visible(current_user),
          query_params: { sort_field: 'plans.updated_at', sort_direction: :desc },
          format: :json
        )
      end
    end
  end
end
