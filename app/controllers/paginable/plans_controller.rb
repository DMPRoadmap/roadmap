class Paginable::PlansController < ApplicationController
  include Paginable
  # /paginable/plans/privately_visible/:page
  def privately_visible
    raise Pundit::NotAuthorizedError unless Paginable::PlanPolicy.new(current_user).privately_visible?
    if params[:page] == 'ALL'
      plans = current_user.active_plans
    else
      plans = current_user.active_plans.page(params[:page])
    end
    paginable_renderise(partial: 'privately_visible', scope: plans)
  end
  # GET /paginable/plans/organisationally_or_publicly_visible/:page
  def organisationally_or_publicly_visible
    raise Pundit::NotAuthorizedError unless Paginable::PlanPolicy.new(current_user).organisationally_or_publicly_visible?
    if params[:page] == 'ALL'
      plans = Plan.organisationally_or_publicly_visible(current_user)
    else
      plans = Plan.organisationally_or_publicly_visible(current_user).page(params[:page])
    end
    paginable_renderise(partial: 'organisationally_or_publicly_visible', scope: plans)
  end
end