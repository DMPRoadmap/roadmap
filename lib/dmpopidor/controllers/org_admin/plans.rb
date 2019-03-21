module Dmpopidor
  module Controllers
    module OrgAdmin
      module Plans

        # GET org_admin/plans
        # In the Org Admin page, Private and Test plans won't be displayed
        def index
          unless current_user.present? && current_user.can_org_admin?
            raise Pundit::NotAuthorizedError
          end

          feedback_ids = Role.where(user_id: current_user.id).reviewer.pluck(:plan_id).uniq
          @feedback_plans = Plan.where(id: feedback_ids)
          @plans = current_user.org.plans.where.not(visibility: [Plan.visibilities[:privately_private_visible], Plan.visibilities[:is_test]])
        end
      end
    end
  end
end