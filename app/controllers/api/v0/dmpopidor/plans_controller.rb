# frozen_string_literal: true

class Api::V0::Dmpopidor::PlansController < Api::V0::BaseController

  before_action :authenticate

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

  private

  def select_research_output(plan_fragment, research_output_id)
    if research_output_id.present?
      plan_fragment.data["research_outputs"] = plan_fragment.data["research_outputs"].select { |r| r == { "dbid" => research_output_id } }
    end
    plan_fragment
  end

  def query_params
    params.permit(:mode, :research_output_id)
  end

end
