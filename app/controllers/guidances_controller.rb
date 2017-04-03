class GuidancesController < ApplicationController
  after_action :verify_authorized
  respond_to :html

  ##
  # GET /guidances
  def admin_index
    authorize Guidance
    @guidances = policy_scope(Guidance)
    @guidance_groups = GuidanceGroup.where(org_id: current_user.org_id)
  end

  ##
  # GET /guidances/1
  def admin_show
    @guidance = Guidance.includes(:guidance_group, :themes).find(params[:id])
    authorize @guidance
  end

  def admin_new
    @guidance = Guidance.new
    authorize @guidance

    load_select_box_content
	end

# TODO: These no longer appear to be in use
	#setup variables for use in the dynamic updating
	def update_phases
    authorize Guidance
    # updates phases, versions, sections and questions based on template selected
    dmptemplate = Template.find(params[:dmptemplate_id])
    # map to title and id for use in our options_for_select
    @phases = dmptemplate.phases.map{|a| [a.title, a.id]}.insert(0, _('Select a phase'))
    @versions = dmptemplate.versions.map{|s| [s.title, s.id]}.insert(0, _('Select a version'))
    @sections = dmptemplate.sections.map{|s| [s.title, s.id]}.insert(0, _('Select a section'))
    @questions = dmptemplate.questions.map{|s| [s.text, s.id]}.insert(0, _('Select a question'))
  end

 def update_versions
    authorize Guidance
    # updates versions, sections and questions based on phase selected
    phase = Phase.find(params[:phase_id])
    # map to name and id for use in our options_for_select
    @versions = phase.versions.map{|s| [s.title, s.id]}.insert(0, _('Select a version'))
    @sections = phase.sections.map{|s| [s.title, s.id]}.insert(0, _('Select a section'))
    @questions = phase.questions.map{|s| [s.text, s.id]}.insert(0, _('Select a question'))
  end

  def update_sections
    authorize Guidance
    # updates sections and questions based on version selected
    version = Version.find(params[:version_id])
    # map to name and id for use in our options_for_select
    @sections = version.sections.map{|s| [s.title, s.id]}.insert(0, _('Select a section'))
    @questions = version.questions.map{|s| [s.text, s.id]}.insert(0, _('Select a question'))
  end

  def update_questions
    authorize Guidance
    # updates songs based on artist selected
    section = Section.find(params[:section_id])
    @questions = section.questions.map{|s| [s.text, s.id]}.insert(0, _('Select a question'))
  end
  
  ##
  # GET /guidances/1/edit
  def admin_edit
    @guidance = Guidance.includes(:themes, :guidance_group).find(params[:id])
    authorize @guidance
    
    load_select_box_content
  end

  ##
  # POST /guidances
  def admin_create
    @guidance = Guidance.new(guidance_params)
    authorize @guidance
    @guidance.text = params["guidance-text"]
    @guidance.question_id = params["question_id"]
    if @guidance.published == true then
      @gg = GuidanceGroup.find(@guidance.guidance_group_id)
      if @gg.published == false || @gg.published.nil? then
        @gg.published = true
        @gg.save
      end
    end

    if @guidance.save
      redirect_to admin_show_guidance_path(@guidance), notice: _('Guidance was successfully created.')
    else
      load_select_box_content
      flash[:notice] = generate_error_notice(@guidance)
      render action: "admin_new"
    end
  end

  ##
  # PUT /guidances/1
  def admin_update
 		@guidance = Guidance.find(params[:id])
    authorize @guidance
		@guidance.text = params["guidance-text"]
		@guidance.question_id = params["question_id"]

    if @guidance.save(guidance_params)
      redirect_to admin_show_guidance_path(params[:guidance]), notice: _('Guidance was successfully updated.')
    else
      load_select_box_content
      flash[:notice] = generate_error_notice(@guidance)
      render action: "admin_edit"
    end
  end

  ##
  # DELETE /guidances/1
  def admin_destroy
   	@guidance = Guidance.find(params[:id])
    authorize @guidance
    @guidance.destroy

    redirect_to admin_index_guidance_path, notice: _('Guidance was successfully deleted.')
	end


  private
    def guidance_params
      # The form on the page is weird. The text and template/section/question stuff is outside of the normal form params
      params.require(:guidance).permit(:guidance_group_id, :theme_ids, :published)
    end
    
    def load_select_box_content
  		#@templates = Template.funders_and_own_templates(current_user.org_id)
      # Replacing weird accessor on Template
      @templates = (Org.funders.collect{|o| o.templates } + current_user.org.templates).flatten

  		@phases = nil
  		@templates.each do |template|
  			if @phases.nil? then
  				@phases = template.phases.all.order('number')
  			else
  				@phases = @phases + template.phases.all.order('number')
  			end
  		end
  		@sections = nil
  		@phases.each do |phase|
  			if @sections.nil? then
  				@sections = phase.sections.all.order('number')
  			else
  				@sections = @sections + phase.sections.all.order('number')
  			end
  		end
  		@questions = nil
  		@sections.each do |section|
  			if @questions.nil? then
  				@questions = section.questions.all.order('number')
  			else
  				@questions = @questions + section.questions.all.order('number')
  			end
  		end
      @themes = Theme.all.order('title')
      @guidance_groups = GuidanceGroup.where(org_id: current_user.org_id).order('name ASC')
    end
end