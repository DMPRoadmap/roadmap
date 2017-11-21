class Paginable::PlansController < ApplicationController
  include Paginable
  #before_action :verify_authorized
  # /paginable/plans/privately_visible/:page
  def privately_visible
    # TODO authorize
    if params[:page] == 'ALL'
      plans = current_user.active_plans
    else
      plans = current_user.active_plans.page(params[:page])
    end
    paginable_renderise(partial: 'privately_visible', scope: plans)
  end
  # GET /paginable/plans/organisationally_or_publicly_visible/:page
  def organisationally_or_publicly_visible
    # TODO authorize
    if params[:page] == 'ALL'
      plans = Plan.organisationally_or_publicly_visible(current_user)
    else
      plans = Plan.organisationally_or_publicly_visible(current_user).page(params[:page])
    end
    paginable_renderise(partial: 'organisationally_or_publicly_visible', scope: plans)
  end
end