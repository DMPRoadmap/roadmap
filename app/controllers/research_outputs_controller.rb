# frozen_string_literal: true

class ResearchOutputsController < ApplicationController

  helper PaginableHelper

  before_action :fetch_plan, except: %i[select_output_type]
  before_action :fetch_research_output, only: %i[create update destroy]

  after_action :verify_authorized

  # GET /plans/:plan_id/research_outputs
  def index
    @research_outputs = ResearchOutput.where(plan_id: @plan.id)
    authorize @research_outputs.first || ResearchOutput.new(plan_id: @plan.id)
  end

  # GET /plans/:plan_id/research_outputs/new
  def new
    @research_output = ResearchOutput.new(plan_id: @plan.id, output_type: "")
    authorize @research_output
  end

  # GET /plans/:plan_id/research_outputs/:id/edit
  def edit
    @research_output = ResearchOutput.find_by(id: params[:id])
    authorize @research_output
  end

  # POST /plans/:plan_id/research_outputs
  def create
    authorize @research_output
  end

  # PATCH/PUT /plans/:plan_id/research_outputs/:id
  def update
    authorize @research_output
  end

  # DELETE /plans/:plan_id/research_outputs/:id
  def destroy
    authorize @research_output
  end

  # ============================
  # = Rails UJS remote methods =
  # ============================

  # GET  /plans/:id/output_type_selection
  def select_output_type
    @plan = Plan.find_by(id: params[:id])
    @research_output = ResearchOutput.new(
      plan: @plan, output_type: output_params[:output_type]
    )
    authorize @research_output
  end

  private

  def output_params
    params.require(:research_output).permit(%i[title abbreviation description output_type])
  end

  # =============
  # = Callbacks =
  # =============
  def fetch_plan
    @plan = Plan.includes(:research_outputs, roles: [:user])
                .find_by(id: params[:plan_id])
    return true if @plan.present?

    redirect_to root_path, alert: _("plan not found")
  end

  def fetch_research_output
    @research_output = ResearchOutput.find_by(id: params[:id])
    return true if @research_output.present? &&
                   @plan.research_outputs.include?(@research_output)

    redirect_to plan_research_outputs_path, alert: _("research output not found")
  end

end
