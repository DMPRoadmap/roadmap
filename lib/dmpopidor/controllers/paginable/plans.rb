module Dmpopidor
    module Controllers
      module Paginable
        module Plans
          # GET /paginable/plans/org_admin/:page
          # Renders only the plans with a visibility superior to privately
          def org_admin
            unless current_user.present? && current_user.can_org_admin?
              raise Pundit::NotAuthorizedError
            end
            paginable_renderise(
              partial: "org_admin",
              scope: current_user.org.plans.where.not(visibility: [
                Plan.visibilities[:privately_visible],
                Plan.visibilities[:is_test]
              ]),
              query_params: { sort_field: 'plans.updated_at', sort_direction: :desc }
            )
          end

          # CHANGES: New Visibility
          # /paginable/plans/administrator_visible/:page
          # Paginable for Administrator Private Visibility
          # Plans that are only visible by the owner of a plan, its collaborators and the org admin
          def administrator_visible
            unless ::Paginable::PlanPolicy.new(current_user).administrator_visible?
              raise Pundit::NotAuthorizedError
            end
            paginable_renderise(
              partial: "administrator_visible",
              scope: Plan.active(current_user),
              query_params: { sort_field: 'plans.updated_at', sort_direction: :desc }
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
              query_params: { sort_field: 'plans.updated_at', sort_direction: :desc }
            )
          end
      end
    end
  end
end