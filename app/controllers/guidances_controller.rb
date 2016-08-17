class GuidancesController < ApplicationController

  # GET /guidances
  # GET /guidances.json
  def admin_index
    if user_signed_in? && current_user.is_org_admin? then
	    @guidances = Guidance.by_organisation(current_user.organisation_id)
	    @guidance_groups = GuidanceGroup.where('organisation_id = ?', current_user.organisation_id )


	    respond_to do |format|
	      format.html # index.html.erb
	      format.json { render json: @guidances }
	    end
    else
			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
		end
  end

  # GET /guidances/1
  # GET /guidances/1.json
  def admin_show
    if user_signed_in? && current_user.is_org_admin? then
	    @guidance = Guidance.find(params[:id])

	    respond_to do |format|
	      format.html # show.html.erb
	      format.json { render json: @guidance }
	    end
   end
  end

  def admin_new
    if user_signed_in? && current_user.is_org_admin? then
	    @guidance = Guidance.new
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
	    respond_to do |format|
	      format.html
	    end
   	end
	end

	#setup variables for use in the dynamic updating
	def update_phases
    # updates phases, versions, sections and questions based on template selected
    dmptemplate = Dmptemplate.find(params[:dmptemplate_id])
    # map to title and id for use in our options_for_select
    @phases = dmptemplate.phases.map{|a| [a.title, a.id]}.insert(0, I18n.t('helpers.select_phase'))
    @versions = dmptemplate.versions.map{|s| [s.title, s.id]}.insert(0, I18n.t('helpers.select_version'))
    @sections = dmptemplate.sections.map{|s| [s.title, s.id]}.insert(0, I18n.t('helpers.select_section'))
    @questions = dmptemplate.questions.map{|s| [s.text, s.id]}.insert(0, I18n.t('helpers.select_question'))

  end

 def update_versions
    # updates versions, sections and questions based on phase selected
    phase = Phase.find(params[:phase_id])
    # map to name and id for use in our options_for_select
    @versions = phase.versions.map{|s| [s.title, s.id]}.insert(0, I18n.t('helpers.select_version'))
    @sections = phase.sections.map{|s| [s.title, s.id]}.insert(0, I18n.t('helpers.select_section'))
    @questions = phase.questions.map{|s| [s.text, s.id]}.insert(0, I18n.t('helpers.select_question'))
  end

  def update_sections
    # updates sections and questions based on version selected
    version = Version.find(params[:version_id])
    # map to name and id for use in our options_for_select
    @sections = version.sections.map{|s| [s.title, s.id]}.insert(0, I18n.t('helpers.select_section'))
    @questions = version.questions.map{|s| [s.text, s.id]}.insert(0, I18n.t('helpers.select_question'))
  end

  def update_questions
    # updates songs based on artist selected
    section = Section.find(params[:section_id])
    @questions = section.questions.map{|s| [s.text, s.id]}.insert(0, I18n.t('helpers.select_question'))
  end


  # GET /guidances/1/edit
  def admin_edit
  	if user_signed_in? && current_user.is_org_admin? then
      @guidance = Guidance.find(params[:id])
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
    else
			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
		end
  end

  # POST /guidances
  # POST /guidances.json
  def admin_create
    if user_signed_in? && current_user.is_org_admin? then
	    @guidance = Guidance.new(params[:guidance])
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
	        format.json { render json: @guidance, status: :created, location: @guidance }
	      else
	        format.html { render action: "new" }
	        format.json { render json: @guidance.errors, status: :unprocessable_entity }
	      end
	    end
    else
			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
		end
  end

  # PUT /guidances/1
  # PUT /guidances/1.json
  def admin_update
 		if user_signed_in? && current_user.is_org_admin? then
   		@guidance = Guidance.find(params[:id])

			@guidance.text = params["guidance-text"]

			@guidance.question_id = params["question_id"]

	    respond_to do |format|
	      if @guidance.update_attributes(params[:guidance])
	        format.html { redirect_to admin_show_guidance_path(params[:guidance]), notice: I18n.t('org_admin.guidance.updated_message') }
	        format.json { head :no_content }
	      else
	        format.html { render action: "edit" }
	        format.json { render json: @guidance.errors, status: :unprocessable_entity }
	      end
	    end
    else
			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
		end
  end


  # DELETE /guidances/1
  # DELETE /guidances/1.json
  def admin_destroy
  	if user_signed_in? && current_user.is_org_admin? then
	   	@guidance = Guidance.find(params[:id])
	    @guidance.destroy

	    respond_to do |format|
	      format.html { redirect_to admin_index_guidance_path }
	      format.json { head :no_content }
	    end
	 	else
			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
		end

	end



end
