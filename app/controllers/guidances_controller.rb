class GuidancesController < ApplicationController
  after_action :verify_authorized

  # GET /guidances
  def admin_index
    authorize Guidance
    @guidances = policy_scope(Guidance)
    @guidance_groups = GuidanceGroup.where('org_id = ?', current_user.org_id )
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /guidances/1
  def admin_show
    @guidance = Guidance.find(params[:id])
    authorize @guidance
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def admin_new
    @guidance = Guidance.new
    authorize @guidance
		@dmptemplates = Dmptemplate.funders_and_own_templates(current_user.org_id)
		@phases = nil
		@dmptemplates.each do |template|
			if @phases.nil? then
				@phases = template.phases.all.order('number')
			else
				@phases = @phases + template.phases.all.order('number')
			end
		end
		@versions = nil
		@phases.each do |phase|
			if @versions.nil? then
				@versions = phase.versions.all.order('title')
			else
				@versions = @versions + phase.versions.all.order('title')
			end
		end
		@sections = nil
		@versions.each do |version|
			if @sections.nil? then
				@sections = version.sections.all.order('number')
			else
				@sections = @sections + version.sections.all.order('number')
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
    respond_to do |format|
      format.html
    end
	end

	#setup variables for use in the dynamic updating
	def update_phases
    authorize Guidance
    # updates phases, versions, sections and questions based on template selected
    dmptemplate = Dmptemplate.find(params[:dmptemplate_id])
    # map to title and id for use in our options_for_select
    @phases = dmptemplate.phases.map{|a| [a.title, a.id]}.insert(0, I18n.t('helpers.select_phase'))
    @versions = dmptemplate.versions.map{|s| [s.title, s.id]}.insert(0, I18n.t('helpers.select_version'))
    @sections = dmptemplate.sections.map{|s| [s.title, s.id]}.insert(0, I18n.t('helpers.select_section'))
    @questions = dmptemplate.questions.map{|s| [s.text, s.id]}.insert(0, I18n.t('helpers.select_question'))
  end

 def update_versions
    authorize Guidance
    # updates versions, sections and questions based on phase selected
    phase = Phase.find(params[:phase_id])
    # map to name and id for use in our options_for_select
    @versions = phase.versions.map{|s| [s.title, s.id]}.insert(0, I18n.t('helpers.select_version'))
    @sections = phase.sections.map{|s| [s.title, s.id]}.insert(0, I18n.t('helpers.select_section'))
    @questions = phase.questions.map{|s| [s.text, s.id]}.insert(0, I18n.t('helpers.select_question'))
  end

  def update_sections
    authorize Guidance
    # updates sections and questions based on version selected
    version = Version.find(params[:version_id])
    # map to name and id for use in our options_for_select
    @sections = version.sections.map{|s| [s.title, s.id]}.insert(0, I18n.t('helpers.select_section'))
    @questions = version.questions.map{|s| [s.text, s.id]}.insert(0, I18n.t('helpers.select_question'))
  end

  def update_questions
    authorize Guidance
    # updates songs based on artist selected
    section = Section.find(params[:section_id])
    @questions = section.questions.map{|s| [s.text, s.id]}.insert(0, I18n.t('helpers.select_question'))
  end


  # GET /guidances/1/edit
  def admin_edit
    @guidance = Guidance.find(params[:id])
    authorize @guidance
    @dmptemplates = Dmptemplate.funders_and_own_templates(current_user.organisation_id)
		@phases = nil
		@dmptemplates.each do |template|
			if @phases.nil? then
				@phases = template.phases.all.order('number')
			else
				@phases = @phases + template.phases.all.order('number')
			end
		end
		@versions = nil
		@phases.each do |phase|
			if @versions.nil? then
				@versions = phase.versions.all.order('title')
			else
				@versions = @versions + phase.versions.all.order('title')
			end
		end
		@sections = nil
		@versions.each do |version|
			if @sections.nil? then
				@sections = version.sections.all.order('number')
			else
				@sections = @sections + version.sections.all.order('number')
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
  end

  # POST /guidances
  def admin_create
    @guidance = Guidance.new(params[:guidance])
    authorize @guidance
    @guidance.text = params["guidance-text"]
    @guidance.question_id = params["question_id"]
      if @guidance.published == true then
        @gg = GuidanceGroup.find(@guidance.guidance_group_ids).first
        if @gg.published == false || @gg.published.nil? then
          @gg.published = true
          @gg.save
        end
      end
    respond_to do |format|
      if @guidance.save
        format.html { redirect_to admin_show_guidance_path(@guidance), notice: I18n.t('org_admin.guidance.created_message') }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /guidances/1
  def admin_update
 		@guidance = Guidance.find(params[:id])
    authorize @guidance
		@guidance.text = params["guidance-text"]
		@guidance.question_id = params["question_id"]
    respond_to do |format|
      if @guidance.update_attributes(params[:guidance])
        format.html { redirect_to admin_show_guidance_path(params[:guidance]), notice: I18n.t('org_admin.guidance.updated_message') }
      else
        format.html { render action: "edit" }
      end
    end
  end


  # DELETE /guidances/1
  def admin_destroy
   	@guidance = Guidance.find(params[:id])
    authorize @guidance
    @guidance.destroy
    respond_to do |format|
      format.html { redirect_to admin_index_guidance_path }
    end
	end

end