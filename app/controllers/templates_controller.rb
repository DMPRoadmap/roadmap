# [+Project:+] DMPRoadmap
# [+Description:+] This controller is responsible for all the actions in the admin interface under templates (e.g. phases, versions, sections, questions, suggested answer) (index; show; create; edit; delete)
# [+Copyright:+] Digital Curation Centre and University of California Curation Center

class TemplatesController < ApplicationController
  respond_to :html
  after_action :verify_authorized

  # GET /dmptemplates
  def admin_index
    authorize Template
    # institutional templates
    all_versions_own_templates = Template.where(org_id: current_user.org_id, customization_of: nil).order(version: :desc)
    current_templates = {}
    # take most recent version of each template
    all_versions_own_templates.each do |temp|
      if current_templates[temp.dmptemplate_id].nil?
        current_templates[temp.dmptemplate_id] = temp
      end
    end
    @templates_own = current_templates.values
    @other_published_version = {}
    current_templates.keys.each do |dmptemplate_id|
      @other_published_version[dmptemplate_id] = Template.where(org_id: current_user.org_id, dmptemplate_id: dmptemplate_id, published: true).present?
    end

    # funders templates
    funders_templates = {}
    Org.includes(:templates).funder.each do |org|
      org.templates.where(customization_of: nil, published: true).order(version: :desc).each do |temp|
        if funders_templates[temp.dmptemplate_id].nil?
          funders_templates[temp.dmptemplate_id] = temp
        end
      end
    end

    @templates_funders = funders_templates.values
    # are any funder templates customized
    @templates_customizations = {}
    Template.where(org_id: current_user.org_id, customization_of: funders_templates.keys).order(version: :desc).each do |temp|
      if @templates_customizations[temp.customization_of].nil?
        @templates_customizations[temp.customization_of] = {}
        @templates_customizations[temp.customization_of][:temp] = temp
        @templates_customizations[temp.customization_of][:published] = temp.published
      else
        @templates_customizations[temp.customization_of][:published] = @templates_customizations[temp.customization_of][:published] || temp.published
      end
    end
  end


  # GET /dmptemplates/1
  def admin_template
    @template = Template.includes(:org, phases: [sections: [questions: [:question_options, :question_format,
          :suggested_answers]]]).find(params[:id])
    # check to see if this is a funder template needing customized
    
    authorize @template
    if @template.org_id != current_user.org_id
      # definitely need to deep_copy the given template
      new_customization = Template.deep_copy(@template)
      new_customization.org_id = current_user.org_id
      new_customization.published = false
      new_customization.customization_of = @template.dmptemplate_id
      # need to mark all Phases, questions, sections as not-modifiable
      new_customization.phases.includes(sections: :questions).each do |phase|
        phase.modifiable = false
        phase.save!
        phase.sections.each do |section|
          section.modifiable = false
          section.save!
          section.questions.each do |question|
            question.modifiable = false
            question.save!
          end
        end
      end
      customizations = Template.includes(:org, phases: [sections: [questions: :suggested_answers ]]).where(org_id: current_user.org_id, customization_of: @template.dmptemplate_id).order(version: :desc)
      if customizations.present?
        # existing customization to port over
        max_version = customizations.first
        new_customization.dmptemplate_id = max_version.dmptemplate_id
        new_customization.version = max_version.version + 1
        # here we rip the customizations out of the old template
        # First, we find any customized phases or sections
        max_version.phases.each do |phase|
          # check if the phase was added as a customization
          if phase.modifiable
            # deep copy the phase and add it to the template
            phase_copy = Phase.deep_copy(phase)
            phase_copy.number = new_customization.phases.length + 1
            phase_copy.template_id = new_customization.id
            phase_copy.save!
          else
            # iterate over the sections to see if any of them are customizations
            phase.sections.each do |section|
              if section.modifiable
                # this is a custom section
                section_copy = Section.deep_copy(section)
                customization_phase = new_customization.phases.includes(:sections).where(number: phase.number).first
                section_copy.phase_id = customization_phase.id
                # custom sections get added to the end
                section_copy.number = customization_phase.sections.length + 1
                # section from phase with corresponding number in the main_template
                section_copy.save!
              else
                # not a customized section, iterate over questions
                customization_phase = new_customization.phases.includes(sections: [questions: :suggested_answers]).where(number: phase.number).first
                customization_section = customization_phase.sections.where(number: section.number).first
                section.questions.each do |question|
                  # find corresponding question in new template
                  customization_question = customization_section.questions.where(number: question.number).first
                  # apply suggested_answers
                  question.suggested_answers.each do |suggested_answer|
                    suggested_answer_copy = SuggestedAnswer.deep_copy(suggested_answer)
                    suggested_answer_copy.org_id = current_user.org_id
                    suggested_answer_copy.question_id = customization_question.id
                    suggested_answer_copy.save!
                  end
                  # guidance attached to a question is also a form of customization
                  # It will soon become an annotation of the question, and be combined with
                  # suggested answers
                  customization_question.guidance = customization_question.guidance + question.guidance
                  customization_question.save!
                end
              end
            end
          end
        end
      else
        # first time customization
        new_customization.version = 0
        new_customization.dmptemplate_id = loop do
          random = rand 2147483647  # max int field in psql
          break random unless Template.exists?(dmptemplate_id: random)
        end
      end
      new_customization.save!
      @template = new_customization
    end
    # needed for some post-migration edge cases
    # some customized templates which were edited
    if @template.published
      new_version = Template.deep_copy(@template)
      new_version.version = @template.version + 1
      new_version.published = false
      new_version.save!
      @template = new_version
    end

    # once the correct template has been generated, we convert it to hash
    @hash = @template.to_hash
  end


  # PUT /dmptemplates/1
  def admin_update
    @template = Template.find(params[:id])
    authorize @template
    if @template.published?
      # published templates cannot be edited
      redirect_to admin_template_template_path(@template), notice: _('Published templates cannot be edited.') and return
    end
    @template.description = params["template-desc"]
    if @template.update_attributes(params[:template])
      if @template.published
        # create a new template version if this template became published
        new_version = Template.deep_copy(@template)
        new_version.version = @template.version + 1
        new_version.published = false
        new_version.save!
      end
      redirect_to admin_template_template_path(), notice: _('Information was successfully updated.')
    else
      redirect_to admin_template_template_path(@template), notice: generate_error_notice(@template)
    end
  end


  # GET /dmptemplates/new
  def admin_new
    authorize Template
  end


  # POST /dmptemplates
  # creates a new template with version 0 and new dmptemplate_id
  def admin_create
    @template = Template.new(params[:template])
    authorize @template
    
    @template.org_id = current_user.org_id
    @template.description = params['template-desc']
    @template.published = false
    @template.version = 0
    @template.visibility = 0
    
    # Generate a unique identifier for the dmptemplate_id
    @template.dmptemplate_id = loop do
      random = rand 2147483647
      break random unless Template.exists?(dmptemplate_id: random)
    end

    if @template.save
      redirect_to admin_template_template_path(@template), notice: _('Information was successfully created.')
    else
      flash[:notice] = generate_error_notice(@template)
      render action: "admin_new"
    end
  end


  # DELETE /dmptemplates/1
  def admin_destroy
    @template = Template.find(params[:id])
    authorize @template
    @template.destroy
    redirect_to admin_index_template_path
  end

  # GET /templates/1
  def admin_template_history
    @template = Template.find(params[:id])
    authorize @template
    @templates = Template.where(dmptemplate_id: @template.dmptemplate_id).order(:version)
  end

end