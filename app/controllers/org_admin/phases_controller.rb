module OrgAdmin
  class PhasesController < ApplicationController
    include Versionable
    
    after_action :verify_authorized

    #show and edit a phase of the template
    # GET /org_admin/phases/[:id]
# TODO: removed the edit local after refactoring the UI
# TODO: refactor the way the current_tab is handled!!
    def show
      phase = Phase.includes(:template, :sections).order(:number).find(params[:id])
      authorize phase
      if !phase.template.latest?
        flash[:notice] = _('You are viewing a historical version of this template. You will not be able to make changes.')
      end
      render('container',
        locals: { 
          partial_path: 'show',
          template: phase.template,
          phase: phase,
          edit: (phase.template.latest? && phase.template.org == current_user.org),
          current_section: params.has_key?(:section_id) ? params[:section_id].to_i : nil,
          question_id: params.has_key?(:question_id) ? params[:question_id].to_i : nil,
          current_tab: params[:r] || 'all-templates'
        })
    end

# TODO: removed the edit local after refactoring the UI
    # GET /org_admin/phases/[:id]/edit
    def edit
      phase = Phase.includes(:template, :sections).order(:number).find(params[:id])
      authorize phase
      if !phase.template.latest?
        flash[:notice] = _('You are viewing a historical version of this template. You will not be able to make changes.')
      end
      render('container',
        locals: { 
          partial_path: 'edit',
          template: phase.template,
          phase: phase,
          edit: (phase.template.latest? && phase.template.org == current_user.org),
          current_section: params.has_key?(:section_id) ? params[:section_id].to_i : nil,
          question_id: params.has_key?(:question_id) ? params[:question_id].to_i : nil,
          current_tab: params[:r] || 'all-templates'
        })
    end

    #preview a phase
    # GET /org_admin/phases/[:id]/preview
    def preview
      phase = Phase.includes(:template).find(params[:id])
      authorize phase
      render('/org_admin/phases/preview', 
        locals: {
          template: phase.template,
          phase: phase,
          current_tab: params[:r] || 'all-templates'
        })
    end

    #add a new phase to a passed template
    # GET /org_admin/phases/new
    def new
      template = Template.includes(:phases).find(params[:template_id])
      if template.latest?
        phase = Phase.new({
          template: template,
          modifiable: true,
          number: (template.phases.length > 0 ? template.phases.collect(&:number).max{|a, b| a.number <=> b.number } + 1 : 1)
        })
        authorize phase
        render('/org_admin/templates/container',
          locals: {
            partial_path: 'add',
            template: template,
            edit: true,
            current_tab: params[:r] || 'all-templates'
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

# TODO: update this so that the description comes through as part of the normal form attributes [:phase][:description]
        phase.description = params["phase-desc"]
        current_tab = params[:r] || 'all-templates'

        if phase.save!
          flash[:notice] = success_message(_('phase'), _('created'))
        else
          flash[:alert] = failed_create_error(phase, _('phase'))
        end
      rescue StandardError => e
        flash[:alert] = _('Unable to create a new version of this template.')
        redirect_to org_admin_template_phase_path(template_id: phase.template.id, id: phase.id, r: current_tab)
      end
      
      if flash[:alert].present?
        redirect_to edit_org_admin_template_path(id: phase.template_id, r: current_tab)
      else
        redirect_to org_admin_template_phase_path(template_id: phase.template.id, id: phase.id, r: current_tab)
      end
    end


    #update a phase of a template
    # PUT /org_admin/phases/[:id]
    def update
      phase = Phase.find(params[:id])
      authorize phase
      begin
        phase = get_modifiable(phase)
      
    # TODO: update this so that the description comes through as part of the normal form attributes [:phase][:description]
        phase.description = params["phase-desc"]
        current_tab = params[:r] || 'all-templates'

        if phase.update!(phase_params)
          flash[:notice] = success_message(_('phase'), _('updated'))
        else
          flash[:alert] = failed_update_error(phase, _('phase'))
        end
      rescue StandardError => e
        flash[:alert] = _('Unable to create a new version of this template.')
      end
      redirect_to org_admin_template_phase_path(template_id: phase.template.id, id: phase.id, r: current_tab)
    end

    #delete a phase
    # DELETE org_admin/phases/[:id]
    def destroy
      phase = Phase.includes(:template).find(params[:id])
      authorize phase
      begin
        phase = get_modifiable(phase)
        current_tab = params[:r] || 'all-templates'
      
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
        redirect_to org_admin_template_phase_path(template.id, phase.id, r: current_tab)
      else
        redirect_to edit_org_admin_template_path(template, r: current_tab)
      end
    end

    private
      def phase_params
        params.require(:phase).permit(:title, :description, :number, :template_id)
      end
  end
end