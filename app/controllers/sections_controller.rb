class SectionsController < ApplicationController
  respond_to :html
  after_action :verify_authorized

  #create a section
  def admin_create
    @section = Section.new(params[:section])
    authorize @section
    @section.description = params["section-desc"]
    @section.modifiable = true
    @phase = section.phase
    if @section.save
      redirect_to admin_show_phase_template_path(id: @section.phase_id,
        :section_id => @section.id, edit: 'true'), notice: _('Information was successfully created.')
    else
      render action: "phases/admin_show"
    end
  end


  #update a section of a template
  def admin_update
    @section = Section.includes(phase: :template).find(params[:id])
    authorize @section
    @section.description = params["section-desc-#{params[:id]}"]
    @phase = @section.phase
    if @section.update_attributes(params[:section])
      redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id , edit: 'true'), notice: _('Information was successfully updated.')
    else
      render action: "phases/admin_show"
    end
  end


  #delete a section and questions
  def admin_destroy
    @section = Section.includes(phase: :template).find(params[:section_id])
    authorize @section
    @phase = @section.phase
    @section.destroy
    redirect_to admin_show_phase_path(id: @phase.id, edit: 'true' ), notice: _('Information was successfully deleted.')
  end
  
end