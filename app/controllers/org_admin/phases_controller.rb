module OrgAdmin
  class PhasesController < ApplicationController
    include Versionable
    
    after_action :verify_authorized

    # GET /org_admin/templates/:template_id/phases/[:id]
    def show
      phase = Phase.includes(:template, :sections).order(:number).find(params[:id])
      authorize phase
      if !phase.template.latest?
        flash[:notice] = _('You are viewing a historical version of this template. You will not be able to make changes.')
      end
      section = params.fetch(:section, nil)
      render('container',
        locals: { 
          partial_path: 'show',
          template: phase.template,
          phase: phase,
          sections: phase.sections.order(:number).select(:id, :title, :modifiable),
          current_section: section.present? ? Section.find_by(id: section, phase_id: phase.id) : nil
        })
    end

    # GET /org_admin/templates/:template_id/phases/[:id]/edit
    def edit
      phase = Phase.includes(:template).find(params[:id])
      authorize phase
      if !phase.template.latest?
        flash[:notice] = _('You are viewing a historical version of this template. You will not be able to make changes.')
      end
      section = params.fetch(:section, nil)
      # User cannot edit a phase if its a customization so redirect to show
      if phase.template.customization_of.present?
        redirect_to org_admin_template_phase_path(template_id: phase.template, id: phase.id, section: section)
      else
        render('container',
          locals: { 
            partial_path: 'edit',
            template: phase.template,
            phase: phase,
            sections: phase.sections.order(:number).select(:id, :title, :modifiable),
            current_section: section.present? ? Section.find_by(id: section, phase_id: phase.id) : nil
          })
      end
    end

    #preview a phase
    # GET /org_admin/phases/[:id]/preview
    def preview
      phase = Phase.includes(:template).find(params[:id])
      authorize phase
      render('/org_admin/phases/preview', 
        locals: {
          template: phase.template,
          phase: phase
        })
    end

    #add a new phase to a passed template
    # GET /org_admin/phases/new
    def new
      template = Template.includes(:phases).find(params[:template_id])
      if template.latest?
        nbr = template.phases.maximum(:number)
        phase = Phase.new({
          template: template,
          modifiable: true,
          number: (nbr.present? ? nbr + 1 : 1)
        })
        authorize phase
        render('/org_admin/templates/container',
          locals: {
            partial_path: 'new',
            template: template,
            phase: phase,
            referrer: request.referrer.present? ? request.referrer : org_admin_templates_path
          })
      else
        render org_admin_templates_path, alert: _('You canot add a phase to a historical version of a template.')
      end
    end
        
    #create a phase
    # POST /org_admin/phases
    def create
      phase = Phase.new(phase_params)
      phase.template = Template.find(params[:template_id])
      authorize phase
      begin
        phase = get_new(phase)
        phase.modifiable = true
        if phase.save!
          flash[:notice] = success_message(_('phase'), _('created'))
        else
          flash[:alert] = failed_create_error(phase, _('phase'))
        end
      rescue StandardError => e
        flash[:alert] = _('Unable to create a new version of this template.')
      end
      if flash[:alert].present?
        redirect_to edit_org_admin_template_path(id: phase.template_id)
      else
        redirect_to edit_org_admin_template_phase_path(template_id: phase.template.id, id: phase.id)
      end
    end

    #update a phase of a template
    # PUT /org_admin/phases/[:id]
    def update
      phase = Phase.find(params[:id])
      authorize phase
      begin
        phase = get_modifiable(phase)
        if phase.update!(phase_params)
          flash[:notice] = success_message(_('phase'), _('updated'))
        else
          flash[:alert] = failed_update_error(phase, _('phase'))
        end
      rescue StandardError => e
        flash[:alert] = _('Unable to create a new version of this template.')
      end
      redirect_to edit_org_admin_template_phase_path(template_id: phase.template.id, id: phase.id)
    end

    #delete a phase
    # DELETE org_admin/phases/[:id]
    def destroy
      phase = Phase.includes(:template).find(params[:id])
      authorize phase
      begin
        phase = get_modifiable(phase)
        template = phase.template
        if phase.destroy!
          flash[:notice] = success_message(_('phase'), _('deleted'))
        else
          flash[:alert] = failed_destroy_error(phase, _('phase'))
        end
      rescue StandardError => e
        flash[:alert] = _('Unable to create a new version of this template.')
      end
      
      if flash[:alert].present?
        redirect_to org_admin_template_phase_path(template.id, phase.id)
      else
        redirect_to edit_org_admin_template_path(template)
      end
    end

    private
      def phase_params
        params.require(:phase).permit(:title, :description, :number)
      end
  end
end