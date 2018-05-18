module OrgAdmin
  class PlansController < ApplicationController
    # GET org_admin/plans
    def index
      # Test auth directly and throw Pundit error sincePundit is unaware of namespacing
      raise Pundit::NotAuthorizedError unless current_user.present? && current_user.can_org_admin?
      
      vals = Role.access_values_for(:reviewer)
      @feedback_plans = Plan.joins(:roles).where('roles.user_id = ? and roles.access IN (?)', current_user.id, vals)
      @plans = current_user.org.plans
    end
    
    # GET org_admin/plans/:id/feedback_complete
    def feedback_complete
      plan = Plan.find(params[:id])
      # Test auth directly and throw Pundit error sincePundit is unaware of namespacing
      raise Pundit::NotAuthorizedError unless current_user.present? && current_user.can_org_admin?
      raise Pundit::NotAuthorizedError unless plan.reviewable_by?(current_user.id)
      
      if plan.complete_feedback(current_user)
        redirect_to org_admin_plans_path, notice: _('%{plan_owner} has been notified that you have finished providing feedback') % { plan_owner: plan.owner.name(false) }
      else
        redirect_to org_admin_plans_path, alert: _('Unable to notify user that you have finished providing feedback.')
      end
    end
    
    # GET /org_admin/download_plans
    def download_plans
      # Test auth directly and throw Pundit error sincePundit is unaware of namespacing
      raise Pundit::NotAuthorizedError unless current_user.present? && current_user.can_org_admin?
      
      org = current_user.org
      file_name = org.name.gsub(/ /, "_")
      header_cols = [
        "#{_('Project title')}",
        "#{_('Template')}",
        "#{_('Organisation')}",
        "#{_('Owner name')}",
        "#{_('Owner email')}",
        "#{_('Updated')}",
        "#{_('Visibility')}"
      ]
      
      plans = CSV.generate do |csv|
        csv << header_cols
        org.plans.includes(template: :org).order(updated_at: :desc).each do |plan|
          owner = plan.owner
          csv << [
            "#{plan.title}", 
            "#{plan.template.title}", 
            "#{plan.owner.org.present? ? plan.owner.org.name : ''}", 
            "#{plan.owner.name(false)}",
            "#{plan.owner.email}",
            "#{l(plan.latest_update.to_date, formats: :short)}",
            "#{Plan.visibility_message(plan.visibility.to_sym).capitalize}"
          ] 
        end
      end

      respond_to do |format|
        format.csv  { send_data plans,  filename: "#{file_name}.csv" }
      end
    end
  end
end