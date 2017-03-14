class PhasesController < ApplicationController
  require 'pp'

  after_action :verify_authorized


	# GET /plans/:plan_id/phases/:id/edit
	def edit

    @plan = Plan.eager_load2(params[:plan_id])
    authorize @plan

    phase_id = params[:id].to_i
    @phase = @plan.template.phases.select {|p| p.id == phase_id}.first

    # the eager_load pulls in ALL answers
    # need to restrict to just ones for this plan
    @plan.template.phases.each do |phase|
      phase.sections do |section|
        section.questions.each do |question|
          question.answers = question.answers.to_a.select {|answer| answer.plan_id == @plan.id}
        end
      end
    end
    
    # Now we need to get all the themed guidance for the plan.
    # TODO: think this through again, there may be a better way to do this.
    #
    # Ultimately we are heading to a map from question id to theme to guidance.
    #
    # get the ids of the dynamically selected guidance groups
    # and keep a map of them so we can extract the names later
    guidance_groups_ids = @plan.plan_guidance_groups.select{|pgg| pgg.selected}.map{|pgg| pgg.guidance_group.id}
    guidance_groups =  GuidanceGroup.includes({guidances: :themes}).find(guidance_groups_ids)

    # create a map from theme to array of guidances
    # where guidance is a hash with the text and the org name
    theme_guidance = {} 

    guidance_groups.each do |guidance_group|
      guidance_group.guidances.each do |guidance|
        guidance.themes.each do |theme|
          title = theme.title
          if !theme_guidance.has_key?(title)
            theme_guidance[title] = Array.new
          end
          theme_guidance[title] << {
            text: guidance.text,
            org: guidance_group.name
          }
        end
      end
    end

    # create hash from question id to theme to guidance array
    # so when we arerendering a question we can grab the guidance out of this
    #
    # question_guidance = {
    #              question.id => {
    #                      theme => [ {text: "......", org: "....."} ]
    #              }
    # }
    @question_guidance = {}
    @plan.questions.each do |question|
      qg = {}
      question.themes.each do |t|
        title = t.title
        qg[title] = theme_guidance[title] if theme_guidance.has_key?(title)
      end
      if !@question_guidance.has_key?(question.id)
        @question_guidance[question.id] = Array.new
      end
      @question_guidance[question.id] = qg
    end

    if !user_signed_in? then
      respond_to do |format|
				format.html { redirect_to edit_user_registration_path }
			end
		end

	end


	# GET /plans/PLANID/phases/PHASEID/status.json
  def status
    @plan = Plan.eager_load(params[:plan_id])
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
    @phase = Phase.eager_load(params[:id])
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
