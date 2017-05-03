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
    
    # Collect all of the published funder templates
    @funder_templates = []
    Org.funders.each do |org|
      Template.dmptemplate_ids.each do |id|
        template = Template.live(id)
        # Its possible for the template to NOT have a published version
        # so only add it if its not nil
        unless template.nil? 
          @funder_templates << {current: template, live: template}
        end
      end
    end
    
    # Collect all of the organisations templates
    @org_templates = []
    Template.dmptemplate_ids.each do |id|
      template = Template.current(id)
      live = Template.live(id)
      
      # Its possible for the template to NOT have a published version
      # so only add it if its not nil
      unless template.nil?
        if template.customization_of.nil?
          @org_templates << {current: template, live: live}
        
        # Check to see if this is a customization of a funder template
        # If so replace the funder's copy
        else
          @funder_templates.delete_if{|t| 
            t[:current].dmptemplate_id == template.customization_of 
          }
          @funder_templates << {current: template, live: live}
        end
      end
    end
    
    @funder_templates = @funder_templates.sort{|x,y| 
      x[:current].title <=> y[:current].title
    }
    @org_templates = @org_templates.sort{|x,y| 
      x[:current].title <=> y[:current].title
    }
  end

  # PUT /org/admin/templates/:id/admin_customize
  # -----------------------------------------------------
  def admin_customize
    @template = Template.find(params[:id])
    authorize @template
    
    customisation = Template.deep_copy(@template)
    customisation.org = current_user.org
    customisation.version = 0
    customisation.customization_of = @template.dmptemplate_id
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

      # Create a new version 
      new_version = Template.deep_copy(@template)
      new_version.version = (@template.version + 1)
      new_version.published = false
      new_version.save

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
    @template = Template.includes(:org, phases: [sections: [questions: [:question_options, :question_format,
          :suggested_answers]]]).find(params[:id])
    authorize @template
    
    @current = Template.current(@template.dmptemplate_id)
    
    unless @template == @current
      flash[:notice] = _('You are viewing a historical version of this template. You will not be able to make changes.')
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