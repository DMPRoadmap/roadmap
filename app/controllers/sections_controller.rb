class SectionsController < ApplicationController
  respond_to :html
  after_action :verify_authorized

  #create a section
  def admin_create
    @section = Section.new(params[:section])
    authorize @section
    @section.description = params["section-desc"]
    @section.modifiable = true
    @phase = @section.phase
    if @section.save
      # Set the template's dirty flag to true
      @section.phase.template.dirty = true
      @section.phase.template.save
      
      redirect_to admin_show_phase_path(id: @section.phase_id,
        :section_id => @section.id, edit: 'true'), notice: _('Information was successfully created.')
    else
      @edit = (@phase.template.org == current_user.org)
      @open = true
      @sections = @phase.sections
      @section_id = @section.id
      @question_id = nil
      flash[:notice] = failed_create_error(@section, _('section'))
      render template: 'phases/admin_show'
    end
  end


  #update a section of a template
  def admin_update
    @section = Section.includes(phase: :template).find(params[:id])
    authorize @section
    @section.description = params["section-desc-#{params[:id]}"]
    @phase = @section.phase
    if @section.update_attributes(params[:section])
      # Set the template's dirty flag to true
      @section.phase.template.dirty = true
      @section.phase.template.save
      
      redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id , edit: 'true'), notice: _('Information was successfully updated.')
    else
      @edit = (@phase.template.org == current_user.org)
      @open = true
      @sections = @phase.sections
      @section_id = @section.id
      @question_id = nil
      flash[:notice] = failed_update_error(@section, _('section'))
      render template: 'phases/admin_show'
    end
  end


  #delete a section and questions
  def admin_destroy
    @section = Section.includes(phase: :template).find(params[:section_id])
    authorize @section
    @phase = @section.phase
    if @section.destroy
      # Set the template's dirty flag to true
      @section.phase.template.dirty = true
      @section.phase.template.save
      
      redirect_to admin_show_phase_path(id: @phase.id, edit: 'true' ), notice: _('Information was successfully deleted.')
    else
      @edit = (@phase.template.org == current_user.org)
      @open = true
      @sections = @phase.sections
      @section_id = @section.id
      @question_id = nil
      
      flash[:notice] = failed_destroy_error(@section, _('section'))
      render template: 'phases/admin_show'
    end
  end
  
end