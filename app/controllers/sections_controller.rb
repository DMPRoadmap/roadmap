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
    current_tab = params[:r] || 'all-templates'
    if @section.save
      @section.phase.template.dirty = true
      @section.phase.template.save!

      redirect_to admin_show_phase_path(id: @section.phase_id, r: current_tab,
        :section_id => @section.id), notice: success_message(_('section'), _('created'))
    else
      @edit = (@phase.template.org == current_user.org)
      @open = true
      @sections = @phase.sections
      @section_id = @section.id
      @question_id = nil
      flash[:alert] = failed_create_error(@section, _('section'))
      if @phase.template.customization_of.present?
        @original_org = Template.where(dmptemplate_id: @phase.template.customization_of).first.org
      else
        @original_org = @phase.template.org
      end
      redirect_to admin_show_phase_path(id: @phase.id, r: current_tab)
    end
  end


  #update a section of a template
  def admin_update
    @section = Section.includes(phase: :template).find(params[:id])
    authorize @section
    @section.description = params["section-desc"]
    @phase = @section.phase
    current_tab = params[:r] || 'all-templates'
    if @section.update_attributes(params[:section])
      @section.phase.template.dirty = true
      @section.phase.template.save!

      redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id, r: current_tab), notice: success_message(_('section'), _('saved'))
    else
      @edit = (@phase.template.org == current_user.org)
      @open = true
      @sections = @phase.sections
      @section_id = @section.id
      @question_id = nil
      flash[:alert] = failed_update_error(@section, _('section'))
      if @phase.template.customization_of.present?
        @original_org = Template.where(dmptemplate_id: @phase.template.customization_of).first.org
      else
        @original_org = @phase.template.org
      end
      redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id, r: current_tab)
    end
  end


  #delete a section and questions
  def admin_destroy
    @section = Section.includes(phase: :template).find(params[:section_id])
    authorize @section
    @phase = @section.phase
    current_tab = params[:r] || 'all-templates'
    if @section.destroy
      @phase.template.dirty = true
      @phase.template.save!
      redirect_to admin_show_phase_path(id: @phase.id, r: current_tab), notice: success_message(_('section'), _('deleted'))
    else
      @edit = (@phase.template.org == current_user.org)
      @open = true
      @sections = @phase.sections
      @section_id = @section.id
      @question_id = nil

      flash[:alert] = failed_destroy_error(@section, _('section'))
      if @phase.template.customization_of.present?
        @original_org = Template.where(dmptemplate_id: @phase.template.customization_of).first.org
      else
        @original_org = @phase.template.org
      end
      redirect_to(admin_show_phase_path(id: @phase.id, r: current_tab))
    end
  end

end