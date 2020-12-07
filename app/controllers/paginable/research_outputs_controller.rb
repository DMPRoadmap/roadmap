# frozen_string_literal: true

module Paginable

  class ResearchOutputsController < ApplicationController

    after_action :verify_authorized
    respond_to :html

    include Paginable

    # GET /paginable/plans/:plan_id/research_outputs
    def index
      @plan = Plan.find_by(id: params[:plan_id])
      authorize @plan
      paginable_renderise(
        partial: "index",
        scope: ResearchOutput.where(plan_id: @plan.id),
        query_params: { sort_field: "research_outputs.title", sort_direction: :asc },
        format: :json
      )
    end

  end

end
