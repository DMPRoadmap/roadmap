# frozen_string_literal: true

class ResearchOutputsController < ApplicationController

  helper PaginableHelper

  before_action :fetch_plan, except: %i[select_output_type repository_search]
  before_action :fetch_research_output, only: %i[edit update destroy]

  after_action :verify_authorized

  # GET /plans/:plan_id/research_outputs
  def index
    @research_outputs = ResearchOutput.includes(:repositories)
                                      .where(plan_id: @plan.id)
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
    args = process_nillable_values(args: args)
    @research_output = ResearchOutput.new(args)
    authorize @research_output

    if @research_output.save
      redirect_to plan_research_outputs_path(@plan),
                  notice: success_message(@research_output, _("added"))
    else
      flash[:alert] = failure_message(@research_output, _("add"))
      render "research_outputs/new"
    end
  end

  # PATCH/PUT /plans/:plan_id/research_outputs/:id
  def update
    args = process_byte_size.merge({ plan_id: @plan.id })
    args = process_nillable_values(args: args)
    authorize @research_output

    # Allow the repository to be removed
    @research_output.repository_id = nil unless args[:repository_id].present?

    # Clear any existing repository selections. If the user has selected any
    # the will be saved via the :repositories_attributes params during :update
    @research_output.repositories.clear

    if @research_output.update(args)
      redirect_to plan_research_outputs_path(@plan),
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

  # GET /plans/:id/repository_search
  def repository_search
    @plan = Plan.find_by(id: params[:id])
    @research_output = ResearchOutput.new(plan: @plan)
    authorize @research_output

    @search_results = Repository.by_type(repo_search_params[:type_filter])
    @search_results = @search_results.by_subject(repo_search_params[:subject_filter])
    @search_results = @search_results.search(repo_search_params[:search_term])

    @search_results = @search_results.order(:name).page(params[:page])
  end

  # PUT /plans/:id/repository_select
  def repository_select
    @plan = Plan.find_by(id: params[:id])
    @research_output = ResearchOutput.new(plan: @plan)
    authorize @research_output

    @research_output
  end

  # PUT /plans/:id/repository_unselect
  def repository_unselect
    @plan = Plan.find_by(id: params[:id])
    @research_output = ResearchOutput.new(plan: @plan)
    authorize @research_output
  end

  private

  def output_params
    params.require(:research_output)
          .permit(%i[title abbreviation description output_type output_type_description
                     sensitive_data personal_data file_size file_size_unit mime_type_id
                     release_date access coverage_start coverage_end coverage_region
                     mandatory_attribution license_id],
                  repositories_attributes: %i[id])
  end

  def repo_search_params
    params.require(:research_output).permit(%i[search_term subject_filter type_filter])
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

  # There are certain fields on the form that are visible based on the selected output_type. If the
  # ResearchOutput previously had a value for any of these and the output_type then changed making
  # one of these arguments invisible, then we need to blank it out here since the Rails form will
  # not send us the value
  def process_nillable_values(args:)
    args[:byte_size] = nil unless args[:byte_size].present?
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
    @research_output = ResearchOutput.includes(:repositories)
                                     .find_by(id: params[:id])
    return true if @research_output.present? &&
                   @plan.research_outputs.include?(@research_output)

    redirect_to plan_research_outputs_path, alert: _("research output not found")
  end

end
