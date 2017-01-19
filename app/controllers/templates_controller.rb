# [+Project:+] DMPRoadmap
# [+Description:+] This controller is responsible for all the actions in the admin interface under templates (e.g. phases, versions, sections, questions, suggested answer) (index; show; create; edit; delete)
# [+Copyright:+] Digital Curation Centre and University of California Curation Center

class TemplatesController < ApplicationController
  after_action :verify_authorized

  # GET /dmptemplates
  def admin_index
    authorize Template
    #institutional templates
    all_versions_own_templates = Template.where(org_id: current_user.org_id, customization_of: nil).order(:version)
    current_templates = {}
    all_versions_own_templates.each do |temp|
      if current_templates[temp.dmptemplate_id].nil?
        current_templates[temp.dmptemplate_id] = temp
      end
    end
    @templates_own = current_templates.values
    #funders templates
    @templates_funders = Template.funders_templates
  end

  # GET /dmptemplates/1
  def admin_template
    @template = Template.find(params[:id])
    authorize @template
  end



  # PUT /dmptemplates/1
  def admin_update
    @dmptemplate = Dmptemplate.find(params[:id])
    authorize @dmptemplate
    @dmptemplate.description = params["template-desc"]
      respond_to do |format|
      if @dmptemplate.update_attributes(params[:dmptemplate])
        format.html { redirect_to admin_template_dmptemplate_path(params[:dmptemplate]), notice: I18n.t('org_admin.templates.updated_message') }
      else
        format.html { render action: "edit" }
      end
    end
  end


  # GET /dmptemplates/new
  def admin_new
    @dmptemplate = Dmptemplate.new
    authorize @dmptemplate
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /dmptemplates
  def admin_create
    @dmptemplate = Dmptemplate.new(params[:dmptemplate])
    @dmptemplate.organisation_id = current_user.organisation.id
    @dmptemplate.description = params['template-desc']
    authorize @dmptemplate
    respond_to do |format|
      if @dmptemplate.save
        format.html { redirect_to admin_template_dmptemplate_path(@dmptemplate), notice: I18n.t('org_admin.templates.created_message') }
      else
        format.html { render action: "admin_new" }
      end
    end
  end



  # DELETE /dmptemplates/1
  def admin_destroy
    @dmptemplate = Dmptemplate.find(params[:id])
    authorize @dmptemplate
    @dmptemplate.destroy
    respond_to do |format|
      format.html { redirect_to admin_index_dmptemplate_path }
    end
  end



  # PHASES

  #show and edit a phase of the template
  def admin_phase
    @phase = Phase.find(params[:id])
    authorize @phase.dmptemplate
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


  #preview a phase
  def admin_previewphase
    @version = Version.find(params[:id])
    authorize @version.phase.dmptemplate
    respond_to do |format|
      format.html
    end
  end


  #add a new phase to a template
  def admin_addphase
    @dmptemplate = Dmptemplate.find(params[:id])
    @phase = Phase.new
    authorize @dmptemplate
    if @dmptemplate.phases.count == 0 then
      @phase.number = '1'
    else
      @phase.number = @dmptemplate.phases.count + 1
    end
    respond_to do |format|
      format.html
    end
  end


  #create a phase
  def admin_createphase
    @phase = Phase.new(params[:phase])
    authorize @phase.dmptemplate
    @phase.description = params["phase-desc"]
    @version = @phase.versions.build
    @version.title = "#{@phase.title} v.1"
    @version.phase_id = @phase.id
    @version.number = 1
    @version.published = false
    respond_to do |format|
      if @phase.save
        format.html { redirect_to admin_phase_dmptemplate_path(:id => @phase.id, :version_id => @version.id, :edit => 'true'), notice: I18n.t('org_admin.templates.created_message') }
      else
        format.html { render action: "admin_phase" }
      end
    end
  end


  #update a phase of a template
  def admin_updatephase
    @phase = Phase.find(params[:id])
    authorize @phase.dmptemplate
    @phase.description = params["phase-desc"]
    respond_to do |format|
      if @phase.update_attributes(params[:phase])
        format.html { redirect_to admin_phase_dmptemplate_path(@phase), notice: I18n.t('org_admin.templates.updated_message') }
      else
        format.html { render action: "admin_phase" }
      end
    end
  end

  #delete a version, sections and questions
  def admin_destroyphase
    @phase = Phase.find(params[:phase_id])
    authorize @phase.dmptemplate
    @dmptemplate = @phase.dmptemplate
    @phase.destroy
    respond_to do |format|
      format.html { redirect_to admin_template_dmptemplate_path(@dmptemplate), notice: I18n.t('org_admin.templates.destroyed_message') }
    end
  end

# VERSIONS

  #update a version of a template
  def admin_updateversion
    @version = Version.find(params[:id])
    authorize @version.phase.dmptemplate
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
      else
        format.html { render action: "admin_phase" }
      end
    end
  end

  #clone a version of a template
  def admin_cloneversion
    @old_version = Version.find(params[:version_id])
    authorize @old_version.phase.dmptemplate
    @version = @old_version.amoeba_dup
    @phase = @version.phase
    respond_to do |format|
      if @version.save
        format.html { redirect_to admin_phase_dmptemplate_path(@phase, :version_id => @version.id, :edit => 'true'), notice: I18n.t('org_admin.templates.updated_message') }
      else
        format.html { render action: "admin_phase" }
      end
    end
  end

  #delete a version, sections and questions
  def admin_destroyversion
    @version = Version.find(params[:version_id])
    authorize @version.phase.dmptemplate
    @phase = @version.phase
    @version.destroy
    respond_to do |format|
      format.html { redirect_to admin_phase_dmptemplate_path(@phase), notice: I18n.t('org_admin.templates.destroyed_message') }
    end
  end


# SECTIONS
  #create a section
  def admin_createsection
    @section = Section.new(params[:section])
    authorize @section.version.phase.dmptemplate
    @section.description = params["section-desc"]
    respond_to do |format|
      if @section.save
        format.html { redirect_to admin_phase_dmptemplate_path(:id => @section.version.phase_id, :version_id => @section.version_id, :section_id => @section.id, :edit => 'true'), notice: I18n.t('org_admin.templates.created_message') }
      else
        format.html { render action: "admin_phase" }
      end
    end
  end


  #update a section of a template
  def admin_updatesection
    @section = Section.find(params[:id])
    authorize @section.version.phase.dmptemplate
    @section.description = params["section-desc-#{params[:id]}"]
    @version = @section.version
    @phase = @version.phase
    respond_to do |format|
      if @section.update_attributes(params[:section])
        format.html { redirect_to admin_phase_dmptemplate_path(:id => @phase.id, :version_id => @version.id, :section_id => @section.id , :edit => 'true'), notice: I18n.t('org_admin.templates.updated_message') }
      else
        format.html { render action: "admin_phase" }
      end
    end
  end


  #delete a section and questions
  def admin_destroysection
    @section = Section.find(params[:section_id])
    authorize @section.version.phase.dmptemplate
    @version = @section.version
    @phase = @version.phase
    @section.destroy
    respond_to do |format|
      format.html { redirect_to admin_phase_dmptemplate_path(:id => @phase.id, :version_id => @version.id,  :edit => 'true' ), notice: I18n.t('org_admin.templates.destroyed_message') }
    end
  end


#  QUESTIONS

  #create a question
  def admin_createquestion
    @question = Question.new(params[:question])
    authorize @question.section.version.phase.dmptemplate
    @question.guidance = params["new-question-guidance"]
    @question.default_value = params["new-question-default-value"]
    respond_to do |format|
      if @question.save
        format.html { redirect_to admin_phase_dmptemplate_path(:id => @question.section.version.phase_id, :version_id => @question.section.version_id, :section_id => @question.section_id, :question_id => @question.id, :edit => 'true'), notice: I18n.t('org_admin.templates.created_message') }
      else
        format.html { render action: "admin_phase" }
      end
    end
  end

  #update a question of a template
  def admin_updatequestion
    @question = Question.find(params[:id])
    authorize @question.section.version.phase.dmptemplate
    @question.guidance = params["question-guidance-#{params[:id]}"]
    @question.default_value = params["question-default-value-#{params[:id]}"]
    @section = @question.section
    @version = @section.version
    @phase = @version.phase
    respond_to do |format|
      if @question.update_attributes(params[:question])
        format.html { redirect_to admin_phase_dmptemplate_path(:id => @phase.id, :version_id => @version.id, :section_id => @section.id, :question_id => @question.id, :edit => 'true'), notice: I18n.t('org_admin.templates.updated_message') }
      else
        format.html { render action: "admin_phase" }
      end
    end
  end

  #delete a version, sections and questions
  def admin_destroyquestion
    @question = Question.find(params[:question_id])
    authorize @question.section.version.phase.dmptemplate
    @section = @question.section
    @version = @section.version
    @phase = @version.phase
    @question.destroy
    respond_to do |format|
      format.html { redirect_to admin_phase_dmptemplate_path(:id => @phase.id, :version_id => @version.id, :section_id => @section.id, :edit => 'true'), notice: I18n.t('org_admin.templates.destroyed_message') }
    end
  end


  #SUGGESTED ANSWERS
  #create suggested answers
  def admin_createsuggestedanswer
    @suggested_answer = SuggestedAnswer.new(params[:suggested_answer])
    authorize @suggested_answer.question.section.version.phase.dmptemplate
    respond_to do |format|
      if @suggested_answer.save
        format.html { redirect_to admin_phase_dmptemplate_path(:id => @suggested_answer.question.section.version.phase_id, :version_id => @suggested_answer.question.section.version_id, :section_id => @suggested_answer.question.section_id, :question_id => @suggested_answer.question.id, :edit => 'true'), notice: I18n.t('org_admin.templates.created_message') }
      else
        format.html { render action: "admin_phase" }
      end
    end
  end


  #update a suggested answer of a template
  def admin_updatesuggestedanswer
    @suggested_answer = SuggestedAnswer.find(params[:id])
    authorize @suggested_answer.question.section.version.phase.dmptemplate
    @question = @suggested_answer.question
    @section = @question.section
    @version = @section.version
    @phase = @version.phase

    respond_to do |format|
      if @suggested_answer.update_attributes(params[:suggested_answer])
        format.html { redirect_to admin_phase_dmptemplate_path(:id => @phase.id, :version_id => @version.id, :section_id => @section.id, :question_id => @question.id, :edit => 'true'), notice: I18n.t('org_admin.templates.updated_message') }
      else
        format.html { render action: "admin_phase" }
      end
    end
  end

  #delete a suggested answer
  def admin_destroysuggestedanswer
    @suggested_answer = SuggestedAnswer.find(params[:suggested_answer])
    authorize @suggested_answer.question.section.version.phase.dmptemplate
    @question = @suggested_answer.question
    @section = @question.section
    @version = @section.version
    @phase = @version.phase
    @suggested_answer.destroy
    respond_to do |format|
      format.html { redirect_to admin_phase_dmptemplate_path(:id => @phase.id, :version_id => @version.id, :section_id => @section.id, :edit => 'true'), notice: I18n.t('org_admin.templates.destroyed_message') }
    end
  end

#  GUIDANCES

  #create a guidance
  def admin_createguidance
    @question = Question.find(params[:question][:id])
    authorize @question.section.version.phase.dmptemplate
    @guidance = Guidance.new(params[:guidance])
    @guidance.question_id = @question.id
    #@question.guidance = params["new-question-guidance"]
    #@question.default_value = params["new-question-default-value"]
    respond_to do |format|
      if @guidance.save
        format.html { redirect_to admin_phase_dmptemplate_path(:id => @question.section.version.phase_id, :version_id => @question.section.version_id, :section_id => @question.section_id, :question_id => @question.id, :edit => 'true'), notice: I18n.t('org_admin.templates.created_message') }
      else
        format.html { render action: "admin_phase" }
      end
    end
  end

  #update a guidance of a template
  def admin_updateguidance
    @question = Question.find(params[:id])
    authorize @question.section.version.phase.dmptemplate
    @question.guidance = params["question-guidance-#{params[:id]}"]
    @question.default_value = params["question-default-value-#{params[:id]}"]
    @section = @question.section
    @version = @section.version
    @phase = @version.phase
    respond_to do |format|
      if @question.update_attributes(params[:question])
        format.html { redirect_to admin_phase_dmptemplate_path(:id => @phase.id, :version_id => @version.id, :section_id => @section.id, :question_id => @question.id, :edit => 'true'), notice: I18n.t('org_admin.templates.updated_message') }
      else
        format.html { render action: "admin_phase" }
      end
    end
  end

  #delete a version, sections and guidance
  def admin_destroyguidance
    @question = Question.find(params[:question_id])
    authorize @question.section.version.phase.dmptemplate
    @section = @question.section
    @version = @section.version
    @phase = @version.phase
    @question.destroy
    respond_to do |format|
      format.html { redirect_to admin_phase_dmptemplate_path(:id => @phase.id, :version_id => @version.id, :section_id => @section.id, :edit => 'true'), notice: I18n.t('org_admin.templates.destroyed_message') }
    end
  end


end