class PhasesController < ApplicationController
  require 'pp'

  after_action :verify_authorized


	# GET /plans/PLANID/phases/PHASEID/edit
	def edit

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



  #show and edit a phase of the template
  def admin_show
    @phase = Phase.find(params[:id])
    authorize @phase
    @edit = params[:edit] == "true" ? true : false
        #verify if there are any sections if not create one
    @sections = @phase.sections
    if !@sections.any?() || @sections.count == 0
      @section = @phase.sections.build
      @section.phase = @phase
      @section.title = ''
      @section.number = 1
      @section.published = true
      @section.modifiable = true
      @section.save
      @new_sec = true
    end
    #verify if section_id has been passed, if so then open that section
    if params.has_key?(:section_id)
      @open = true
      @section_id = params[:section_id].to_i
    end
    if params.has_key?(:question_id)
      @question_id = params[:question_id].to_i
    end
  end


  #preview a phase
  def admin_preview
    @phase = Phase.find(params[:id])
    authorize @phase
    @template = @phase.template
  end


  #add a new phase to a passed template
  def admin_add
    @template = Template.find(params[:id])
    @phase = Phase.new
    phase.template = @template
    authorize @phase
    @phase.number = @template.phases.count + 1
  end


  #create a phase
  def admin_create
    @phase = Phase.new(params[:phase])
    authorize @phase
    @phase.description = params["phase-desc"]
    @phase.modifiable = true
    if @phase.save
      redirect_to admin_show_phase_path(id: @phase.id, edit: 'true'), notice: I18n.t('org_admin.templates.created_message')
    else
      render action: "admin_show"
    end
  end


  #update a phase of a template
  def admin_update
    @phase = Phase.find(params[:id])
    authorize @phase
    @phase.description = params["phase-desc"]
    if @phase.update_attributes(params[:phase])
      redirect_to admin_show_phase_path(@phase), notice: I18n.t('org_admin.templates.updated_message')
    else
      render action: "admin_show"
    end
  end

  #delete a phase
  def admin_destroy
    @phase = Phase.find(params[:phase_id])
    authorize @phase
    @template = @phase.template
    @phase.destroy
    redirect_to admin_template_template_path(@template), notice: I18n.t('org_admin.templates.destroyed_message')
  end



end
