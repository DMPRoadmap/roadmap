# frozen_string_literal: true

module Dmpopidor
  module OrgAdmin
    # Customized code for OrgAdmin PlansController
    module PlansController
      # GET org_admin/plans/:id/feedback_complete
      # CHANGES : Added feedback requestor to plan
      # rubocop:disable Metrics/AbcSize
      def feedback_complete
        plan = ::Plan.find(params[:id])
        requestor = ::User.find(plan.feedback_requestor.id)
        # Test auth directly and throw Pundit error sincePundit is
        # unaware of namespacing
        raise Pundit::NotAuthorizedError unless current_user.present? && current_user.can_org_admin?
        raise Pundit::NotAuthorizedError unless plan.reviewable_by?(current_user.id)

        if plan.complete_feedback(current_user)
          # rubocop:disable Metrics/LineLength
          redirect_to(org_admin_plans_path,
                      notice: format(_('%<plan_owner>s has been notified that you have finished providing feedback'), plan_owner: requestor.name(false)))
          # rubocop:enable Metrics/LineLength
        else
          redirect_to org_admin_plans_path,
                      alert: _('Unable to notify user that you have finished providing feedback.')
        end
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end