# [+Project:+] DMPRoadmap
# [+Description:+] This controller is responsible for all the actions in the admin interface under templates (e.g. phases, versions, sections, questions, suggested answer) (index; show; create; edit; delete)
# [+Copyright:+] Digital Curation Centre and University of California Curation Center

class TemplatesController < ApplicationController
  respond_to :html
  after_action :verify_authorized

  # GET /org/admin/templates/:id/admin_index
  # -----------------------------------------------------
  def admin_index
    authorize Template

    funder_templates, org_templates = [], []

    # Get all of the unique template family ids (dmptemplate_id) for each funder and the current org
    funder_ids = Org.funders.includes(:templates).collect{|f| f.templates.where(published: true).valid.collect{|ft| ft.dmptemplate_id } }.flatten.uniq
    org_ids = current_user.org.templates.where(customization_of: nil).valid.collect{|t| t.dmptemplate_id }.flatten.uniq

    org_ids.each do |id|
      current = Template.current(id)
      live = Template.live(id)
      org_templates << {current: current, live: live}
    end
    funder_ids.each do |id|
      funder_live = Template.live(id)
      current = Template.org_customizations(id, current_user.org_id)
      # if we have a current template, check to see if there is a live version
      live = current.nil? ? nil : Template.live(current.dmptemplate_id)
      # need a current version, default to funder live if no custs exist
      current = funder_live unless current.present?

      funder_templates << {current: current, live: live, funder_live: funder_live,  stale: funder_live.updated_at > current.created_at}
    end

    @funder_templates = funder_templates.sort{|x,y|
      x[:current].title <=> y[:current].title
    }
    @org_templates = org_templates.sort{|x,y|
      x[:current].title <=> y[:current].title
    }
  end

  # GET /org/admin/templates/:id/admin_customize
  # -----------------------------------------------------
  def admin_customize
    @template = Template.find(params[:id])
    authorize @template

    customisation = Template.deep_copy(@template)
    customisation.org = current_user.org
    customisation.version = 0
    customisation.customization_of = @template.dmptemplate_id
    customisation.dmptemplate_id = loop do
      random = rand 2147483647
      break random unless Template.exists?(dmptemplate_id: random)
    end
    customisation.save

    customisation.phases.includes(:sections, :questions).each do |phase|
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

    redirect_to admin_template_template_path(customisation)
  end

  # GET /org/admin/templates/:id/admin_transfer_customization
  # the funder template's id is passed through here
  # -----------------------------------------------------
  def admin_transfer_customization
    @template = Template.includes(:org).find(params[:id])
    authorize @template
    new_customization = Template.deep_copy(@template)
    new_customization.org_id = current_user.org_id
    new_customization.published = false
    new_customization.customization_of = @template.dmptemplate_id
    new_customization.dirty = true
    new_customization.phases.includes(sections: :questions).each do |phase|
      phase.modifiable = false
      phase.save
      phase.sections.each do |section|
        section.modifiable = false
        section.save
        section.questions.each do |question|
          question.modifiable = false
          question.save
        end
      end
    end
    customizations = Template.includes(:org, phases:[sections: [questions: :annotations]]).where(org_id: current_user.org_id, customization_of: @template.dmptemplate_id).order(version: :desc)
    # existing version to port over
    max_version = customizations.first
    new_customization.dmptemplate_id = max_version.dmptemplate_id
    new_customization.version = max_version.version + 1
    # here we rip the customizations out of the old template
    # First, we find any customzed phases or sections
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
            customization_phase = new_customization.phases.includes(sections: [questions: :annotations]).where(number: phase.number).first
            customization_section = customization_phase.sections.where(number: section.number).first
            section.questions.each do |question|
              # find corresponding question in new template
              customization_question = customization_section.questions.where(number: question.number).first
              # apply annotations
              question.annotations.where(org_id: current_user.org_id).each do |annotation|
                annotation_copy = Annotation.deep_copy(annotation)
                annotation_copy.question_id = customization_question.id
                annotation_copy.save!
              end
            end
          end
        end
      end
    end
    new_customization.save
    redirect_to admin_template_template_path(new_customization)
  end

  # PUT /org/admin/templates/:id/admin_publish
  # -----------------------------------------------------
  def admin_publish
    @template = Template.find(params[:id])
    authorize @template

    current = Template.current(@template.dmptemplate_id)

    # Only allow the current version to be updated
    if current != @template
      redirect_to admin_template_template_path(@template), notice: _('You can not publish a historical version of this template.')

    else
      # Unpublish the older published version if there is one
      live = Template.live(@template.dmptemplate_id)
      if !live.nil? and self != live
        live.published = false
        live.save!
      end
      # Set the dirty flag to false
      @template.dirty = false
      @template.published = true
      @template.save

      flash[:notice] = _('Your template has been published and is now available to users.')

      redirect_to admin_index_template_path(current_user.org)
    end
  end

  # PUT /org/admin/templates/:id/admin_unpublish
  # -----------------------------------------------------
  def admin_unpublish
    template = Template.find(params[:id])
    authorize template

    # Unpublish the live version
    @template = Template.live(template.dmptemplate_id)

    if @template.nil?
      flash[:notice] = _('That template is not currently published.')
    else
      @template.published = false
      @template.save
      flash[:notice] = _('Your template is no longer published. Users will not be able to create new DMPs for this template until you re-publish it')
    end

    redirect_to admin_index_template_path(current_user.org)
  end

  # GET /org/admin/templates/:id/admin_template
  # -----------------------------------------------------
  def admin_template
    @template = Template.includes(:org, phases: [sections: [questions: [:question_options, :question_format, :annotations]]]).find(params[:id])
    authorize @template

    @current = Template.current(@template.dmptemplate_id)

    if @template == @current
      # If the template is published
      if @template.published?
        # We need to create a new, editable version
        new_version = Template.deep_copy(@template)
        new_version.version = (@template.version + 1)
        new_version.published = false
        new_version.save
        @template = new_version
#        @current = Template.current(@template.dmptemplate_id)
      end
    else
      flash[:notice] = _('You are viewing a historical version of this template. You will not be able to make changes.')
    end

    # If the template is published
    if @template.published?
      # We need to create a new, editable version
      new_version = Template.deep_copy(@template)
      new_version.version = (@template.version + 1)
      new_version.published = false
      new_version.save
      @template = new_version
    end

    # once the correct template has been generated, we convert it to hash
    @hash = @template.to_hash
  end


  # PUT /org/admin/templates/:id/admin_update
  # -----------------------------------------------------
  def admin_update
    @template = Template.find(params[:id])
    authorize @template

    current = Template.current(@template.dmptemplate_id)

    # Only allow the current version to be updated
    if current != @template
      redirect_to admin_template_template_path(@template), notice: _('You can not edit a historical version of this template.')

    else
      if @template.description != params["template-desc"] ||
              @template.title != params[:template][:title]
        @template.dirty = true
      end

      @template.description = params["template-desc"]
      if @template.update_attributes(params[:template])
        flash[:notice] = _('Information was successfully updated.')

      else
        flash[:notice] = failed_update_error(@template, _('template'))
      end

      @hash = @template.to_hash
      render 'admin_template'
    end
  end


  # GET /org/admin/templates/:id/admin_new
  # -----------------------------------------------------
  def admin_new
    authorize Template
  end


  # POST /org/admin/templates/:id/admin_create
  # -----------------------------------------------------
  def admin_create
    # creates a new template with version 0 and new dmptemplate_id
    @template = Template.new(params[:template])
    authorize @template
    @template.org_id = current_user.org.id
    @template.description = params['template-desc']

    if @template.save
      redirect_to admin_template_template_path(@template), notice: _('Information was successfully created.')
    else
      @hash = @template.to_hash
      flash[:notice] = failed_create_error(@template, _('template'))
      render action: "admin_new"
    end
  end


  # DELETE /org/admin/templates/:id/admin_destroy
  # -----------------------------------------------------
  def admin_destroy
    @template = Template.find(params[:id])
    authorize @template

    current = Template.current(@template.dmptemplate_id)

    # Only allow the current version to be destroyed
    if current == @template
      if @template.destroy
        redirect_to admin_index_template_path
      else
        @hash = @template.to_hash
        flash[:notice] = failed_destroy_error(@template, _('template'))
        render admin_template_template_path(@template)
      end
    else
      flash[:notice] = _('You cannot delete historical versions of this template.')
      redirect_to admin_index_template_path
    end
  end

  # GET /org/admin/templates/:id/admin_template_history
  # -----------------------------------------------------
  def admin_template_history
    @template = Template.find(params[:id])
    authorize @template
    @templates = Template.where(dmptemplate_id: @template.dmptemplate_id).order(:version)
    @current = Template.current(@template.dmptemplate_id)
  end

end
