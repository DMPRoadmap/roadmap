# frozen_string_literal: true

module Paginable
  # Controller for paginating/sorting/searching the research_outputs table
  class ResearchOutputsController < ApplicationController
    include Paginable

    after_action :verify_authorized

    # GET /paginable/plans/:plan_id/research_outputs
    def index
      @plan = Plan.find_by(id: params[:plan_id])
      # Same assignment as app/controllers/research_outputs_controller.rb
      research_outputs = ResearchOutput.includes(:repositories).where(plan_id: @plan.id)
      # Same authorize handling as app/controllers/research_outputs_controller.rb
      # `|| ResearchOutput.new(plan_id: @plan.id)` prevents Pundit::NotDefinedError when a direct
      # GET /paginable/plans/:id/research_outputs request is made on a plan with 0 research_outputs
      authorize(research_outputs.first || ResearchOutput.new(plan_id: @plan.id))
      paginable_renderise(
        partial: 'index',
        scope: research_outputs,
        query_params: { sort_field: 'research_outputs.title' },
        format: :json
      )
    end
  end
end
