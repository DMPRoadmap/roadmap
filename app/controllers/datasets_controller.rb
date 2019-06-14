# frozen_string_literal: true

class DatasetsController < ApplicationController

  after_action :verify_authorized 

  # GET /plans/:plan_id/datasets
  def index
    begin
      @plan = Plan.find(params[:plan_id])
      @datasets = @plan.datasets

      authorize @plan
      render('plans/datasets', locals: { plan: @plan, datasets: @datasets })
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = _("There is no plan associated with id %{id}") % {
        id: params[:id]
      }
      redirect_to(:controller => 'plans', :action => 'index')
    end
  end

  def destroy
    @plan = Plan.find(params[:plan_id])
    @dataset = Dataset.find(params[:id])
    authorize @plan
    if @dataset.destroy
        flash[:notice] = success_message(@plan, _("deleted"))
        redirect_to(:action => 'index')
    else
      flash[:alert] = failure_message(@plan, _("delete"))
      redirect_to(:action => 'index')
    end
  end

  

end
