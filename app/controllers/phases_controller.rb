class PhasesController < ApplicationController
  require 'pp'

  after_action :verify_authorized


    # GET /plans/:plan_id/phases/:id/edit
    def edit
    @plan, @phase = Plan.load_for_phase(params[:plan_id], params[:id])
    # check if plan exists first
    if @plan.nil?
      raise Pundit::NotAuthorizedError, "Must have access to plan"
    end
    if @phase.nil?
      raise Pundit::NotAuthorizedError, "Phase must belong to plan"
    end
    # authorization done on plan so found in plan_policy
    authorize @plan
    @answers = @plan.answers.reduce({}){ |m, a| m[a.question_id] = a; m }
    @readonly = !@plan.editable_by?(current_user.id)

    # Now we need to get all the themed guidance for the plan.
    # TODO: think this through again, there may be a better way to do this.
    #
    # Ultimately we are heading to a map from question id to theme to guidance.
    #
    # get the ids of the dynamically selected guidance groups
    # and keep a map of them so we can extract the names later
    guidance_groups_ids = @plan.guidance_groups.map{|pgg| pgg.id}
    guidance_groups =  GuidanceGroup.includes({guidances: :themes}).where(published: true, id: guidance_groups_ids)

    # create a map from theme to array of guidances
    # where guidance is a hash with the text and the org name
    theme_guidance = {}

    guidance_groups.includes(guidances:[:themes]).each do |guidance_group|
      guidance_group.guidances.each do |guidance|
        if guidance.published
          guidance.themes.each do |theme|
            title = theme.title
            if !theme_guidance.has_key?(title)
              theme_guidance[title] = Array.new
            end
            theme_guidance[title] << {
              text: guidance.text,
              org: guidance_group.name + ':'
            }
          end
        end
      end
    end

    questions = []
    # Appends all the questions for a given phase into questions Array.
    @phase.sections.each do |section|
      section.questions.each do |question|
        questions.push(question)
      end
    end
    @question_guidance = {}
    # Puts in question_guidance (key/value) entries where key is the question id and value is a hash.
    # Each question id hash has (key/value) entries where key is a theme and value is an Array of {text, org} objects
    # Example hash
    # question_guidance = { question.id =>
    #                         { theme => [ {text: "......", org: "....."} ] }
    #                     }
    questions.each do |question|
      qg = {}
      question.themes.each do |t|
        title = t.title
        qg[title] = theme_guidance[title] if theme_guidance.has_key?(title)
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
    @phase = Phase.eager_load(:sections).find_by('phases.id = ?', params[:id])
    authorize @phase

    @current = Template.current(@phase.template.dmptemplate_id)
    @edit = (@phase.template.org == current_user.org) && (@phase.template == @current)
    #@edit = params[:edit] == "true" ? true : false

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
    if @phase.template.customization_of.present?
      @original_org = Template.where(dmptemplate_id: @phase.template.customization_of).first.org
    else
      @original_org = @phase.template.org
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
    @phase.template = @template
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
      @phase.template.dirty = true
      @phase.template.save!

      redirect_to admin_show_phase_path(id: @phase.id, edit: 'true'), notice: _('Information was successfully created.')
    else
      flash[:notice] = failed_create_error(@phase, _('phase'))
      @template = @phase.template
      render "admin_add"
    end
  end


  #update a phase of a template
  def admin_update
    @phase = Phase.find(params[:id])
    authorize @phase
    @phase.description = params["phase-desc"]
    if @phase.update_attributes(params[:phase])
      @phase.template.dirty = true
      @phase.template.save!

      redirect_to admin_show_phase_path(@phase), notice: _('Information was successfully updated.')
    else
      @sections = @phase.sections
      @template = @phase.template
      # These params may not be available in this context so they may need
      # to be set to true without the check
      @edit = true
      @open = !params[:section_id].nil?
      @section_id = (params[:section_id].nil? ? nil : params[:section_id].to_i)
      @question_id = (params[:question_id].nil? ? nil : params[:question_id].to_i)
      flash[:notice] = failed_update_error(@phase, _('phase'))
      if @phase.template.customization_of.present?
        @original_org = Template.where(dmptemplate_id: @phase.template.customization_of).first.org
      else
        @original_org = @phase.template.org
      end
      render 'admin_show'
    end
  end

  #delete a phase
  def admin_destroy
    @phase = Phase.find(params[:phase_id])
    authorize @phase
    @template = @phase.template
    if @phase.destroy
      @template.dirty = true
      @template.save!

      redirect_to admin_template_template_path(@template), notice: _('Information was successfully deleted.')
    else
      @sections = @phase.sections

      # These params may not be available in this context so they may need
      # to be set to true without the check
      @edit = true
      @open = !params[:section_id].nil?
      @section_id = (params[:section_id].nil? ? nil : params[:section_id].to_i)
      @question_id = (params[:question_id].nil? ? nil : params[:question_id].to_i)
      flash[:notice] = failed_destroy_error(@phase, _('phase'))
      if @phase.template.customization_of.present?
        @original_org = Template.where(dmptemplate_id: @phase.template.customization_of).first.org
      else
        @original_org = @phase.template.org
      end
      render 'admin_show'
    end
  end

end
