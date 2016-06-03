# [+Project:+] DMPonline v4
# [+Description:+] This controller is responsible for all the actions in the admin interface under templates (e.g. phases, versions, sections, questions, suggested answer) (index; show; create; edit; delete)
# [+Copyright:+] Digital Curation Centre 

class DmptemplatesController < ApplicationController

  # GET /dmptemplates
  # GET /dmptemplates.json
  def admin_index
    if user_signed_in? && current_user.is_org_admin? then
    	#institutional templates
	    @dmptemplates_own = Dmptemplate.own_institutional_templates(current_user.organisation_id)

	    #funders templates
	    @dmptemplates_funders = Dmptemplate.funders_templates

     respond_to do |format|
	      format.html # index.html.erb
	   end
    else
			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
		end
  end

  # GET /dmptemplates/1
  # GET /dmptemplates/1.json
  def admin_template
    if user_signed_in? && current_user.is_org_admin? then
	    @dmptemplate = Dmptemplate.find(params[:id])

	    respond_to do |format|
	      format.html # show.html.erb
	      format.json { render json: @dmptemplate }
	    end
    else
			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
		end
  end



  # PUT /dmptemplates/1
  # PUT /dmptemplates/1.json
  def admin_update
 	if user_signed_in? && current_user.is_org_admin? then
   		@dmptemplate = Dmptemplate.find(params[:id])
   		@dmptemplate.description = params["template-desc"]

 		  respond_to do |format|
	      if @dmptemplate.update_attributes(params[:dmptemplate])
	        format.html { redirect_to admin_template_dmptemplate_path(params[:dmptemplate]), notice: I18n.t('org_admin.templates.updated_message') }
	        format.json { head :no_content }
	      else
	        format.html { render action: "edit" }
	        format.json { render json: @dmptemplate.errors, status: :unprocessable_entity }
	      end
	  	end
  	else
			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
	end
  end


    # GET /dmptemplates/new
  # GET /dmptemplates/new.json
  def admin_new
    if user_signed_in? && current_user.is_org_admin? then
	    @dmptemplate = Dmptemplate.new

	    respond_to do |format|
	      format.html # new.html.erb
	      format.json { render json: @dmptemplate }
	    end
    else
			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
		end
  end

  # POST /dmptemplates
  # POST /dmptemplates.json
  def admin_create
    if user_signed_in? && current_user.is_org_admin? then
	    @dmptemplate = Dmptemplate.new(params[:dmptemplate])
	    @dmptemplate.organisation_id = current_user.organisation.id
	    @dmptemplate.description = params['template-desc']

	    respond_to do |format|
	      if @dmptemplate.save
	        format.html { redirect_to admin_template_dmptemplate_path(@dmptemplate), notice: I18n.t('org_admin.templates.created_message') }
	        format.json { render json: @dmptemplate, status: :created, location: @dmptemplate }
	      else
	        format.html { render action: "admin_new" }
	        format.json { render json: @dmptemplate.errors, status: :unprocessable_entity }
	      end
	    end
    else
			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
		end
  end



  # DELETE /dmptemplates/1
  # DELETE /dmptemplates/1.json
  def admin_destroy
  	if user_signed_in? && current_user.is_org_admin? then
	   	@dmptemplate = Dmptemplate.find(params[:id])
	    @dmptemplate.destroy

	    respond_to do |format|
	      format.html { redirect_to admin_index_dmptemplate_path }
	      format.json { head :no_content }
	    end
	 	else
			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
		end
	end



	# PHASES

	#show and edit a phase of the template
	def admin_phase
		if user_signed_in? && current_user.is_org_admin? then

			@phase = Phase.find(params[:id])

			if !params.has_key?(:version_id) then
				@edit = 'false'
				#check for the most recent published version, if none is available then return the most recent one
				versions = @phase.versions.where('published = ?', true).order('updated_at DESC')
				if versions.any?() then
					@version = versions.first
				else
					@version = @phase.versions.order('updated_at DESC').first
				end
				# When the version_id is passed as an argument
			else
				@edit = params[:edit]
				@version = Version.find(params[:version_id])
			end

			#verify if there are any sections if not create one
			@sections = @version.sections
			if !@sections.any?() || @sections.count == 0 then
				@section = @version.sections.build
				@section.title = ''
				@section.version_id = params[:version_id]
				@section.number = 1
				@section.organisation_id = current_user.organisation.id
				@section.published = true
                @section.save
                @new_sec = true
			end

			#verify if section_id has been passed, if so then open that section
			if params.has_key?(:section_id) then
				@open = true
				@section_id = params[:section_id].to_i
			end

			if params.has_key?(:question_id) then
				@question_id = params[:question_id].to_i
			end

			respond_to do |format|
				format.html
			end
		end
	end
	
	#preview a phase
	def admin_previewphase
		if user_signed_in? && current_user.is_org_admin? then
			
			@version = Version.find(params[:id])
			
				
			respond_to do |format|
				format.html
			end
		end	
	end


	#add a new phase to a template
	def admin_addphase
		if user_signed_in? && current_user.is_org_admin? then
			@dmptemplate = Dmptemplate.find(params[:id])
			@phase = Phase.new
			if @dmptemplate.phases.count == 0 then
				@phase.number = '1'
			else
				@phase.number = @dmptemplate.phases.count + 1
			end

			respond_to do |format|
              format.html
            end
		end
	end

	#create a phase
	def admin_createphase
    if user_signed_in? && current_user.is_org_admin? then
	 	@phase = Phase.new(params[:phase])
	    @phase.description = params["phase-desc"]
	    @version = @phase.versions.build
	    @version.title = "#{@phase.title} v.1"
	    @version.phase_id = @phase.id
	    @version.number = 1
	    @version.published = false

	    respond_to do |format|
	      if @phase.save
	        format.html { redirect_to admin_phase_dmptemplate_path(:id => @phase.id, :version_id => @version.id, :edit => 'true'), notice: I18n.t('org_admin.templates.created_message') }
         	format.json { head :no_content }
	      else
	        format.html { render action: "admin_phase" }
	        format.json { render json: @phase.errors, status: :unprocessable_entity }
	      end
			end
		end
  end


	#update a phase of a template
	def admin_updatephase
		if user_signed_in? && current_user.is_org_admin? then
   		@phase = Phase.find(params[:id])
		@phase.description = params["phase-desc"]

	    respond_to do |format|
	      if @phase.update_attributes(params[:phase])
	        format.html { redirect_to admin_phase_dmptemplate_path(@phase), notice: I18n.t('org_admin.templates.updated_message') }
	        format.json { head :no_content }
	      else
	        format.html { render action: "admin_phase" }
	        format.json { render json: @phase.errors, status: :unprocessable_entity }
	      end
	    end
		end
	end

	#delete a version, sections and questions
	def admin_destroyphase
  	if user_signed_in? && current_user.is_org_admin? then
	   	@phase = Phase.find(params[:phase_id])
	   	@dmptemplate = @phase.dmptemplate
	    @phase.destroy

	    respond_to do |format|
	      format.html { redirect_to admin_template_dmptemplate_path(@dmptemplate), notice: I18n.t('org_admin.templates.destroyed_message') }
	      format.json { head :no_content }
	    end
	 	end
	end

# VERSIONS

	#update a version of a template
	def admin_updateversion
		if user_signed_in? && current_user.is_org_admin? then
	   		@version = Version.find(params[:id])
            @version.description = params["version-desc"]
            @phase = @version.phase

            if @version.published && !@phase.dmptemplate.published then
                @phase.dmptemplate.published = true
            end
            
            if @version.published == true then
                @all_versions = @phase.versions.where('published = ?', true)
                @all_versions.each do |v|
                    if v.id != @version.id && v.published == true then
                        v.published = false
                        v.save
                    end
                end
            end    

		    respond_to do |format|
		      if @version.update_attributes(params[:version])
		        format.html { redirect_to admin_phase_dmptemplate_path(@phase, :version_id =>  @version.id, :edit => 'false'), notice: I18n.t('org_admin.templates.updated_message') }
		        format.json { head :no_content }
		      else
		        format.html { render action: "admin_phase" }
		        format.json { render json: @version.errors, status: :unprocessable_entity }
		      end
		    end
			end
		end

		#clone a version of a template
		def admin_cloneversion
			if user_signed_in? && current_user.is_org_admin? then
                @old_version = Version.find(params[:version_id])
				@version = @old_version.amoeba_dup
				@phase = @version.phase

		    respond_to do |format|
		      if @version.save
		        format.html { redirect_to admin_phase_dmptemplate_path(@phase, :version_id => @version.id, :edit => 'true'), notice: I18n.t('org_admin.templates.updated_message') }
		        format.json { head :no_content }
		      else
		        format.html { render action: "admin_phase" }
		        format.json { render json: @version.errors, status: :unprocessable_entity }
		      end
		    end
			end
		end

	#delete a version, sections and questions
	def admin_destroyversion
  	if user_signed_in? && current_user.is_org_admin? then
	   	@version = Version.find(params[:version_id])
	   	@phase = @version.phase
	    @version.destroy

	    respond_to do |format|
	      format.html { redirect_to admin_phase_dmptemplate_path(@phase), notice: I18n.t('org_admin.templates.destroyed_message') }
	      format.json { head :no_content }
	    end
	 	end
	end

# SECTIONS

	#create a section
	def admin_createsection
    if user_signed_in? && current_user.is_org_admin? then
	 	@section = Section.new(params[:section])
	    @section.description = params["section-desc"]

	    respond_to do |format|
	      if @section.save
	        format.html { redirect_to admin_phase_dmptemplate_path(:id => @section.version.phase_id, :version_id => @section.version_id, :section_id => @section.id, :edit => 'true'), notice: I18n.t('org_admin.templates.created_message') }
         	format.json { head :no_content }
	      else
	        format.html { render action: "admin_phase" }
	        format.json { render json: @section.errors, status: :unprocessable_entity }
	      end
			end
		end
  end


	#update a section of a template
	def admin_updatesection
		if user_signed_in? && current_user.is_org_admin? then
	   		@section = Section.find(params[:id])
	   		@section.description = params["section-desc-#{params[:id]}"]
	    	@version = @section.version
				@phase = @version.phase

				respond_to do |format|
		      if @section.update_attributes(params[:section])
		        format.html { redirect_to admin_phase_dmptemplate_path(:id => @phase.id, :version_id => @version.id, :section_id => @section.id , :edit => 'true'), notice: I18n.t('org_admin.templates.updated_message') }
		        format.json { head :no_content }
		      else
		        format.html { render action: "admin_phase" }
		        format.json { render json: @section.errors, status: :unprocessable_entity }
		      end
		    end
			end
	end


	#delete a section and questions
	def admin_destroysection
  	if user_signed_in? && current_user.is_org_admin? then
	   	@section = Section.find(params[:section_id])
	   	@version = @section.version
	   	@phase = @version.phase
	    @section.destroy

	    respond_to do |format|
	      format.html { redirect_to admin_phase_dmptemplate_path(:id => @phase.id, :version_id => @version.id,  :edit => 'true' ), notice: I18n.t('org_admin.templates.destroyed_message') }
	      format.json { head :no_content }
	    end
	 	end
	end


#  QUESTIONS

	#create a question
	def admin_createquestion
    if user_signed_in? && current_user.is_org_admin? then
	 	@question = Question.new(params[:question])
	    @question.guidance = params["new-question-guidance"]
	    @question.default_value = params["new-question-default-value"]


	    respond_to do |format|
	      if @question.save
	        format.html { redirect_to admin_phase_dmptemplate_path(:id => @question.section.version.phase_id, :version_id => @question.section.version_id, :section_id => @question.section_id, :question_id => @question.id, :edit => 'true'), notice: I18n.t('org_admin.templates.created_message') }
         	format.json { head :no_content }
	      else
	        format.html { render action: "admin_phase" }
	        format.json { render json: @question.errors, status: :unprocessable_entity }
	      end
			end
		end
  end

	#update a question of a template
	def admin_updatequestion
		if user_signed_in? && current_user.is_org_admin? then
	   		@question = Question.find(params[:id])
				@question.guidance = params["question-guidance-#{params[:id]}"]
				@question.default_value = params["question-default-value-#{params[:id]}"]
	    	@section = @question.section
				@version = @section.version
				@phase = @version.phase

				respond_to do |format|
		      if @question.update_attributes(params[:question])
		        format.html { redirect_to admin_phase_dmptemplate_path(:id => @phase.id, :version_id => @version.id, :section_id => @section.id, :question_id => @question.id, :edit => 'true'), notice: I18n.t('org_admin.templates.updated_message') }
		        format.json { head :no_content }
		      else
		        format.html { render action: "admin_phase" }
		        format.json { render json: @question.errors, status: :unprocessable_entity }
		      end
		    end
			end
		end

	#delete a version, sections and questions
	def admin_destroyquestion
  	if user_signed_in? && current_user.is_org_admin? then
	   	@question = Question.find(params[:question_id])
	   	@section = @question.section
			@version = @section.version
	   	@phase = @version.phase
	    @question.destroy

	    respond_to do |format|
	      format.html { redirect_to admin_phase_dmptemplate_path(:id => @phase.id, :version_id => @version.id, :section_id => @section.id, :edit => 'true'), notice: I18n.t('org_admin.templates.destroyed_message') }
	      format.json { head :no_content }
	    end
	 	end
	end


	#SUGGESTED ANSWERS
	#create suggested answers
	def admin_createsuggestedanswer
        if user_signed_in? && current_user.is_org_admin? then
                @suggested_answer = SuggestedAnswer.new(params[:suggested_answer])

            respond_to do |format|
              if @suggested_answer.save
                format.html { redirect_to admin_phase_dmptemplate_path(:id => @suggested_answer.question.section.version.phase_id, :version_id => @suggested_answer.question.section.version_id, :section_id => @suggested_answer.question.section_id, :question_id => @suggested_answer.question.id, :edit => 'true'), notice: I18n.t('org_admin.templates.created_message') }
                format.json { head :no_content }
              else
                format.html { render action: "admin_phase" }
                format.json { render json: @suggested_answer.errors, status: :unprocessable_entity }
              end
                end
         end
     end

	#update a suggested answer of a template
	def admin_updatesuggestedanswer
		if user_signed_in? && current_user.is_org_admin? then
	   		@suggested_answer = SuggestedAnswer.find(params[:id])
            @question = @suggested_answer.question
            @section = @question.section
            @version = @section.version
            @phase = @version.phase

				respond_to do |format|
		      if @suggested_answer.update_attributes(params[:suggested_answer])
		        format.html { redirect_to admin_phase_dmptemplate_path(:id => @phase.id, :version_id => @version.id, :section_id => @section.id, :question_id => @question.id, :edit => 'true'), notice: I18n.t('org_admin.templates.updated_message') }
		        format.json { head :no_content }
		      else
		        format.html { render action: "admin_phase" }
		        format.json { render json: @suggested_answer.errors, status: :unprocessable_entity }
		      end
		    end
			end
		end

	#delete a suggested answer
	def admin_destroysuggestedanswer
  	if user_signed_in? && current_user.is_org_admin? then
	   	@suggested_answer = SuggestedAnswer.find(params[:suggested_answer])
	   	@question = @suggested_answer.question
	   	@section = @question.section
			@version = @section.version
	   	@phase = @version.phase
	    @suggested_answer.destroy

	    respond_to do |format|
	      format.html { redirect_to admin_phase_dmptemplate_path(:id => @phase.id, :version_id => @version.id, :section_id => @section.id, :edit => 'true'), notice: I18n.t('org_admin.templates.destroyed_message') }
	      format.json { head :no_content }
	    end
	 	end
	end




end
