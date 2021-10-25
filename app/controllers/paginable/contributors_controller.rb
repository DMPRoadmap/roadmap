# frozen_string_literal: true

module Paginable

  class ContributorsController < ApplicationController

    after_action :verify_authorized
    respond_to :html

    include Paginable

    # GET /paginable/plans/:plan_id/contributors
    # GET /paginable/plans/:plan_id/contributors/index/:page
    def index
      @plan = Plan.find_by(id: params[:plan_id])
      authorize @plan
      paginable_renderise(
        partial: "index",
        scope: Contributor.where(plan_id: @plan.id),
        query_params: { sort_field: "contributors.name", sort_direction: :asc },
        format: :json
      )
    end

  end

end
