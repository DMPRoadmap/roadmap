# frozen_string_literal: true

class ResearchOutputsController < ApplicationController

  helper PaginableHelper

  before_action :fetch_plan, except: %i[select_output_type repository_search]
  before_action :fetch_research_output, only: %i[edit update destroy]

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
    authorize @research_output
  end

  # POST /plans/:plan_id/research_outputs
  def create
    args = process_byte_size.merge({ plan_id: @plan.id })
    @research_output = ResearchOutput.new(args)
    authorize @research_output

    if @research_output.save
      redirect_to plan_research_outputs_path(@plan),
                  notice: success_message(@research_output, _("added"))
    else
      redirect_to plan_research_outputs_path(@plan),
                  alert: failure_message(@research_output, _("add"))
    end
  end

  # PATCH/PUT /plans/:plan_id/research_outputs/:id
  def update
    args = process_byte_size.merge({ plan_id: @plan.id })
    authorize @research_output

    if @research_output.update(args)
      redirect_to edit_plan_research_output_path(@plan, @research_output),
                  notice: success_message(@research_output, _("saved"))
    else
      redirect_to edit_plan_research_output_path(@plan, @research_output),
                  alert: failure_message(@research_output, _("save"))
    end
  end

  # DELETE /plans/:plan_id/research_outputs/:id
  def destroy
    authorize @research_output

    if @research_output.destroy
      redirect_to plan_research_outputs_path(@plan),
                  notice: success_message(@research_output, _("removed"))
    else
      redirect_to plan_research_outputs_path(@plan),
                  alert: failure_message(@research_output, _("remove"))
    end
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

  # POST /plans/:id/repository_search
  def repository_search
    @plan = Plan.find_by(id: params[:id])
    @research_output = ResearchOutput.new(
      plan: @plan, output_type: output_params[:output_type]
    )
    authorize @research_output

    # rubocop:disable Style/ConditionalAssignment
    if repository_search_params[:facet].present?
      @search_results = Repository.by_facet(repository_search_params[:facet])
                                  .order(:name)
    else
      @search_results = Repository.search(repository_search_params[:repository_search_term])
                                  .order(:name)
    end
    # rubocop:enable Style/ConditionalAssignment
  end

  private

  def output_params
    params.require(:research_output)
          .permit(%i[title abbreviation description output_type output_type_description
                     sensitive_data personal_data file_size file_size_unit mime_type_id
                     release_date access coverage_start coverage_end coverage_region
                     mandatory_attribution repository_id])
  end

  def repository_search_params
    params.require(:research_output).permit(%i[repository_search_term facet])
  end

  def process_byte_size
    args = output_params

    if args[:file_size].present?
      byte_size = 0.bytes + case args[:file_size_unit]
                            when "pb"
                              args[:file_size].to_f.petabytes
                            when "tb"
                              args[:file_size].to_f.terabytes
                            when "gb"
                              args[:file_size].to_f.gigabytes
                            when "mb"
                              args[:file_size].to_f.megabytes
                            else
                              args[:file_size].to_i
                            end

      args[:byte_size] = byte_size
    end

    args.delete(:file_size)
    args.delete(:file_size_unit)
    args
  end

  # =============
  # = Callbacks =
  # =============

  def fetch_plan
    @plan = Plan.find_by(id: params[:plan_id])
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
