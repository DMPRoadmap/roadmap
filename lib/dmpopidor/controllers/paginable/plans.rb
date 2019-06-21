module Dmpopidor
    module Controllers
      module Paginable
        module Plans
          # GET /paginable/plans/org_admin/:page
          # Renders only the plans with a visibility superior to privately_private
          def org_admin
            unless current_user.present? && current_user.can_org_admin?
              raise Pundit::NotAuthorizedError
            end
            paginable_renderise(
              partial: "org_admin",
              scope: current_user.org.plans.where.not(:visibility => 4),
              query_params: { sort_field: 'plans.updated_at', sort_direction: :desc }
            )
          end
        end
      end
    end
  end