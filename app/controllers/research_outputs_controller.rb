# frozen_string_literal: true

class ResearchOutputsController < ApplicationController

  helper PaginableHelper

  before_action :fetch_plan
  before_action :fetch_research_output, only: %i[edit update destroy]

  after_action :verify_authorized

  # GET /plans/:plan_id/research_outputs
  def index
    authorize @plan
    @research_outputs = ResearchOutput.where(plan_id: @plan.id)
  end

  # GET /plans/:plan_id/research_outputs/new
  def new
    authorize @plan
  end

  # GET /plans/:plan_id/research_outputs/:id/edit
  def edit
    authorize @plan
  end

  # POST /plans/:plan_id/research_outputs
  def create
    authorize @plan
  end

  # PATCH/PUT /plans/:plan_id/research_outputs/:id
  def update
    authorize @plan
  end

  # DELETE /plans/:plan_id/research_outputs/:id
  def destroy
    authorize @plan
  end

  private

  def output_params
    params.require(:research_output).permit(:title)
  end

  # =============
  # = Callbacks =
  # =============
  def fetch_plan
    @plan = Plan.includes(:research_outputs).find_by(id: params[:plan_id])
    return true if @plan.present?

    redirect_to root_path, alert: _("plan not found")
  end

  def fetch_research_output
    @output = ResearchOutput.find_by(id: params[:id])
    return true if @output.present? &&
                   @plan.research_outputs.include?(@output)

    redirect_to plan_research_outputs_path, alert: _("research output not found")
  end

end
