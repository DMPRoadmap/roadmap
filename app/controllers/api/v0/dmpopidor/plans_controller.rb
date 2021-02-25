# frozen_string_literal: true

class Api::V0::Dmpopidor::PlansController < Api::V0::BaseController

  before_action :authenticate
  include MadmpExportHelper

  def show
    @plan = Plan.find(params[:id])
    @plan_fragment = @plan.json_fragment.dup
    research_output_id = query_params[:research_output_id] ? query_params[:research_output_id].to_i : nil
    # check if the user has permissions to use the API
    unless Api::V0::Dmpopidor::PlanPolicy.new(@user, @plan).show?
      raise Pundit::NotAuthorizedError
    end

    @plan_fragment = select_research_output(@plan_fragment, research_output_id)
    if query_params[:mode] == "slim"
      respond_with @plan_fragment.data
    else
      respond_with @plan_fragment.get_full_fragment
    end
  end

  def rda_export
    plan = Plan.find(params[:id])
    plan_fragment = plan.json_fragment
    dmp_id = plan_fragment.id
    # check if the user has permissions to use the API
    unless Api::V0::Dmpopidor::PlanPolicy.new(@user, plan).rda_export?
      raise Pundit::NotAuthorizedError
    end

    rda_export = madmp_transform(
      plan_fragment.get_full_fragment,
      load_export_template("rda"),
      dmp_id
    )

    # respond_with @plan_fragment.get_full_fragment
    respond_with rda_export
  end

  private

  def select_research_output(plan_fragment, research_output_id)
    if research_output_id.present?
      plan_fragment.data["researchOutput"] = plan_fragment.data["researchOutput"].select {
        |r| r == { "dbid" => research_output_id }
      }
    end
    plan_fragment
  end

  def query_params
    params.permit(:mode, :research_output_id)
  end

end
