class Paginable::PlansController < ApplicationController
  include Paginable
  # /paginable/plans/privately_visible/:page
  def privately_visible
    raise Pundit::NotAuthorizedError unless Paginable::PlanPolicy.new(current_user).privately_visible?
    plans = Plan.active(current_user)
    if params[:search].present?
      plans = plans.search(params[:search])
      plans = params[:page] == 'ALL' ? plans.page(1) : plans.page(params[:page])
    else
      plans = params[:page] == 'ALL' ? plans : plans.page(params[:page])
    end
    paginable_renderise(partial: 'privately_visible', scope: plans)
  end
  # GET /paginable/plans/organisationally_or_publicly_visible/:page
  def organisationally_or_publicly_visible
    raise Pundit::NotAuthorizedError unless Paginable::PlanPolicy.new(current_user).organisationally_or_publicly_visible?
    plans = Plan.organisationally_or_publicly_visible(current_user)
    if params[:search].present?
      plans = plans.search(params[:search])
      plans = params[:page] == 'ALL' ? plans.page(1) : plans.page(params[:page])
    else
      plans = params[:page] == 'ALL' ? plans : plans.page(params[:page])
    end
    paginable_renderise(partial: 'organisationally_or_publicly_visible', scope: plans)
  end
end