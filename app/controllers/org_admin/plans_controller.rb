module OrgAdmin
  class PlansController < ApplicationController
    after_action :verify_authorized

    def index
      authorize Plan
    
      vals = Role.access_values_for(:reviewer)
      @feedback_plans = Plan.joins(:roles).where('roles.user_id = ? and roles.access IN (?)', current_user.id, vals)
      @plans = current_user.org.plans
    end
    
    # GET org_admin/plans/:id/feedback_complete
    def feedback_complete
      plan = Plan.find(params[:id])
      authorize plan
      
      if plan.complete_feedback(current_user)
        redirect_to org_admin_plans_path, notice: _('%{plan_owner} has been notified that you have finished providing feedback') % { plan_owner: plan.owner.name(false) }
      else
        redirect_to org_admin_plans_path, alert: _('Unable to notify user that you have finished providing feedback.')
      end
    end
  end
end