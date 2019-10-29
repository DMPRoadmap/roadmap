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
              scope: current_user.org.plans.where.not(visibility: [
                Plan.visibilities[:privately_private_visible],
                Plan.visibilities[:is_test]
              ]),
              query_params: { sort_field: 'plans.updated_at', sort_direction: :desc }
            )
          end

          # CHANGES: New Visibility
          # /paginable/plans/privately_private_visible/:page
          # Paginable for Privately Private Visibility
          # Plans that are only visible by the owner of a plan and its collaborators
          def privately_private_visible
            unless ::Paginable::PlanPolicy.new(current_user).privately_private_visible?
              raise Pundit::NotAuthorizedError
            end
            paginable_renderise(
              partial: "privately_private_visible",
              scope: Plan.active(current_user),
              query_params: { sort_field: 'plans.updated_at', sort_direction: :desc }
            )
          end
        end
      end
    end
  end