# frozen_string_literal: true

class ResearchOutputsController < ApplicationController

  after_action :verify_authorized 

  # GET /plans/:plan_id/research_outputs
  def index
    begin
      @plan = Plan.find(params[:plan_id])
      @research_outputs = @plan.research_outputs
      @research_output_types = ResearchOutputType.all

      authorize @plan
      render("plans/research_outputs", locals: { plan: @plan, research_outputs: @research_outputs, 
                                                 research_output_types: @research_output_types })
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = _("There is no plan associated with id %{id}") % {
        id: params[:id]
      }
      redirect_to(:controller => "plans", :action => "index")
    end
  end

  def update
    @plan = Plan.find(params[:plan_id])
    @research_output = ResearchOutput.find(params[:id])
    attrs = research_output_params

    authorize @plan

    if @research_output.update(attrs)
      render json: {
        "html" => render_to_string(partial: "research_outputs/list", locals: {
            plan: @plan,
            research_outputs: @plan.research_outputs,
            readonly: false
        })
      }
    else
      flash[:alert] = failure_message(@research_output, _("update"))
      redirect_to(action: "index")
    end
  end

  def destroy
    @plan = Plan.find(params[:plan_id])
    @research_output = ResearchOutput.find(params[:id])
    research_output_fragment = @research_output.json_fragment 
    authorize @plan
    if @research_output.destroy
      research_output_fragment.destroy!
      flash[:notice] = success_message(@research_output, _("deleted"))
    else
      flash[:alert] = failure_message(@research_output, _("delete"))
    end
    redirect_to(action: "index")
  end

  def sort
    @plan = Plan.find(params[:plan_id])
    authorize @plan
    params[:updated_order].each_with_index do |id, index|
      ResearchOutput.find(id).update(order: index + 1)
    end
    head :ok
  end

  def create_remote
    @plan = Plan.find(params[:plan_id])
    max_order = @plan.research_outputs.maximum("order") + 1
    @plan.research_outputs.create(
      abbreviation: "Research Output #{max_order}",
      fullname: "New research output #{max_order}",
      is_default: false,
      type: ResearchOutputType.find_by(label: "Dataset"),
      order: max_order
    )
    @plan.research_outputs.toggle_default

    authorize @plan

    render json: {
      "html" => render_to_string(partial: "research_outputs/list", locals: {
        plan: @plan,
        research_outputs: @plan.research_outputs,
        readonly: false
      })
    }
  end

  private

  def research_output_params
    params.require(:research_output)
          .permit(:id, :plan_id, :abbreviation, :fullname)
  end

end
