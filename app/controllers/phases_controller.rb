class PhasesController < ApplicationController
  require 'pp'

  after_action :verify_authorized

  TEXTAREA = QuestionFormat.where(title: "Text area").first.id
  TEXTFIELD = QuestionFormat.where(title: "Text field").first.id
  RADIO = QuestionFormat.where(title: "Radio buttons").first.id
  CHECKBOX = QuestionFormat.where(title: "Check box").first.id
  DROPDOWN = QuestionFormat.where(title: "Dropdown").first.id
  MULTI = QuestionFormat.where(title: "Multi select box").first.id
  
	# GET /plans/PLANID/phases/PHASEID/edit
	def edit
    
    @textarea = TEXTAREA
    @textfield = TEXTFIELD
    @radio = RADIO
    @checkbox = CHECKBOX
    @dropdown = DROPDOWN
    @multi = MULTI

    @plan = Plan.find(params[:plan_id])
    authorize @plan

    @plan_data = @plan.to_hash

    phase_id = params[:id].to_i
		@phase = Phase.find(phase_id)
    @phase_data = @plan_data["template"]["phases"].select {|p| p["id"] == phase_id}.first

    if !user_signed_in? then
      respond_to do |format|
				format.html { redirect_to edit_user_registration_path }
			end
		end

	end
  
  
	# GET /plans/PLANID/phases/PHASEID/status.json
  def status
    @plan = Plan.find(params[:plan_id])
    authorize @plan
    if user_signed_in? && @plan.readable_by?(current_user.id) then
      respond_to do |format|
        format.json { render json: @plan.status }
      end
    else
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end
  end


end
