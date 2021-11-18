# frozen_string_literal: true

class Api::V0::Madmp::PlansController < Api::V0::BaseController

  before_action :authenticate
  include MadmpExportHelper

  def show
    plan = Plan.find(params[:id])
    plan_fragment = plan.json_fragment
    selected_research_outputs = query_params[:research_outputs]&.map(&:to_i) || plan.research_output_ids
    # check if the user has permissions to use the API
    unless Api::V0::Madmp::PlanPolicy.new(@user, plan).show?
      raise Pundit::NotAuthorizedError
    end

    respond_to do |format|
      format.json
      render "shared/export/madmp_export_templates/default/plan", locals: {
        dmp: plan_fragment, selected_research_outputs: selected_research_outputs
      }
      return
    end
  end

  def rda_export
    plan = Plan.find(params[:id])
    plan_fragment = plan.json_fragment
    selected_research_outputs = query_params[:research_outputs]&.map(&:to_i) || plan.research_output_ids
    # check if the user has permissions to use the API
    unless Api::V0::Madmp::PlanPolicy.new(@user, plan).rda_export?
      raise Pundit::NotAuthorizedError
    end

    respond_to do |format|
      format.json
      render "shared/export/madmp_export_templates/rda/plan", locals: {
        dmp: plan_fragment, selected_research_outputs: selected_research_outputs
      }
      return
    end
  end

  private

  def select_research_output(plan_fragment, selected_research_outputs)
    plan_fragment.data["researchOutput"] = plan_fragment.data["researchOutput"].select {
      |r| r == { "dbid" => research_output_id }
    }
    plan_fragment
  end

  def query_params
    params.permit(:mode, research_outputs: [])
  end

end
