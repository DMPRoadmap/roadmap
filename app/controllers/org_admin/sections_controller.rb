module OrgAdmin
  class SectionsController < ApplicationController
    include Versionable
    
    respond_to :html
    after_action :verify_authorized

    # GET /org_admin/templates/[:template_id]/phases/[:phase_id]/sections
    def index
      authorize Section.new
      phase = Phase.includes(:template, :sections).find(params[:phase_id])
      edit = (current_user.can_modify_templates?  &&  (phase.template.org_id == current_user.org_id))
      render partial: 'index', 
        locals: { 
          template: phase.template, 
          phase: phase, 
          sections: phase.sections, 
          current_section: phase.sections.first,
          current_tab: params[:r] || 'all-templates',
          edit: edit 
        }
    end

    # GET /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:id]
    def show
      section = Section.find(params[:id])
      authorize section
      section = Section.includes(questions: [:annotations, :question_options]).find(params[:id])
      render partial: 'show', locals: { 
        template: Template.find(params[:template_id]),
        section: section 
      }
    end

    # GET /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:id]/edit
    def edit
      section = Section.includes({phase: :template}, questions: [:annotations, :question_options]).find(params[:id])
      authorize section
      render partial: 'edit', 
        locals: { 
          template: section.phase.template, 
          phase: section.phase, 
          section: section
        }
    end

    # POST /org_admin/templates/[:template_id]/phases/[:phase_id]/sections
    def create
      phase = Phase.includes(:template, :sections).find(params[:phase_id])
      section = Section.new(section_params.merge({ phase_id: phase.id }))
      authorize section
      begin
        section = get_new(section)
        phase = section.phase

        if section.save
          flash[:notice] = success_message(_('section'), _('created'))
          redirect_to edit_org_admin_template_phase_path(template_id: phase.template_id, id: section.phase_id, section_id: section.id)
        else
          flash[:alert] = failed_create_error(section, _('section'))
          redirect_to edit_org_admin_template_phase_path(template_id: phase.template_id, id: section.phase_id)
        end
      rescue StandardError => e
        flash[:alert] = _('Unable to create a new version of this template.')
        redirect_to edit_org_admin_template_phase_path(template_id: phase.template_id, id: phase.id)
      end
    end

    # PUT /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:id]
    def update
      section = Section.includes(phase: :template).find(params[:id])
      authorize section
      begin
        section = get_modifiable(section)
        section.description = params["section-desc"]
        phase = section.phase

        if section.update!(section_params)
          flash[:notice] = success_message(_('section'), _('saved'))
        else
          flash[:alert] = failed_update_error(section, _('section'))
        end
      rescue StandardError => e
        flash[:alert] = _('Unable to create a new version of this template.')
      end
      
      if flash[:alert].present?
        redirect_to edit_org_admin_template_phase_path(template_id: phase.template.id, id: phase.id, section_id: section.id)
      else
        redirect_to edit_org_admin_template_phase_path(template_id: phase.template.id, id: phase.id, section_id: section.id)
      end
    end

    # DELETE /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:id]
    def destroy
      section = Section.includes(phase: :template).find(params[:id])
      authorize section
      begin
        section = get_modifiable(section)
        phase = section.phase
      
        if section.destroy!
          flash[:notice] = success_message(_('section'), _('deleted'))
        else
          flash[:alert] = failed_destroy_error(section, _('section'))
        end
      rescue StandardError => e
        flash[:alert] = _('Unable to create a new version of this template.')
      end
      
      if flash[:alert].present?
        redirect_to(edit_org_admin_template_phase_path(template_id: phase.template.id, id: phase.id))
      else
        redirect_to(edit_org_admin_template_phase_path(template_id: phase.template.id, id: phase.id))
      end
    end
    
    private
      def section_params
        params.require(:section).permit(:title, :description, :number, :phase_id)
      end
  end
end