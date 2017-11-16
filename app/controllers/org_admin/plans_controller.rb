module OrgAdmin
  class PlansController < ApplicationController
    after_action :verify_authorized

    def index
      authorize Plan
    
      vals = Role.access_values_for(:reviewer)
      @feedback_plans = Plan.joins(:roles).where('roles.user_id = ? and roles.access IN (?)', current_user.id, vals)
      @plans = current_user.org.plans
    end
  end
end