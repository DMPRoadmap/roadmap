class PhasesController < ApplicationController
  require 'pp'

  after_action :verify_authorized


  # GET /plans/:plan_id/phases/:id/edit
  def edit
    plan = Plan.find(params[:plan_id])
    authorize plan
    
    plan, phase = Plan.load_for_phase(params[:plan_id], params[:id])
    
    readonly = !plan.editable_by?(current_user.id)
    
    guidance_groups_ids = plan.guidance_groups.collect(&:id)
    
    guidance_groups =  GuidanceGroup.where(published: true, id: guidance_groups_ids)
    # Since the answers have been pre-fetched through plan (see Plan.load_for_phase)
    # we create a hash whose keys are question id and value is the answer associated
    answers = plan.answers.reduce({}){ |m, a| m[a.question_id] = a; m }
    
    render('/phases/edit', locals: {
      base_template_org: phase.template.base_org,
      plan: plan, phase: phase, readonly: readonly,
      question_guidance: plan.guidance_by_question_as_hash,
      guidance_groups: guidance_groups,
      answers: answers })
  end


    # GET /plans/PLANID/phases/PHASEID/status.json
  def status
    @plan = Plan.eager_load(params[:plan_id])
    authorize @plan
    if user_signed_in? && @plan.readable_by?(current_user.id) then
      respond_to do |format|
        format.json { render json: @plan.status }
      end
    else
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end
  end

  #show and edit a phase of the template
  def admin_show
    @phase = Phase.includes(:template, :sections).order(:number).find(params[:id])
    authorize @phase

    @current = Template.current(@phase.template.dmptemplate_id)
    @edit = (@phase.template.org == current_user.org) && (@phase.template == @current)

    if params.has_key?(:question_id)
      @question_id = params[:question_id].to_i
    end
    if @phase.template.customization_of.present?
      @original_org = Template.where(dmptemplate_id: @phase.template.customization_of).first.org
    else
      @original_org = @phase.template.org
    end
    
    if @phase.template != @current
      flash[:notice] = _('You are viewing a historical version of this template. You will not be able to make changes.')
    end
    
    render('/org_admin/templates/container',
      locals: {
        partial_path: 'admin_show',
        phase: @phase,
        template: @phase.template,
        edit: @edit,
        current_section: params.has_key?(:section_id) ? params[:section_id].to_i : nil,
        current_tab: params[:r] || 'all-templates'
      })
  end


  #preview a phase
  def admin_preview
    @phase = Phase.find(params[:id])
    authorize @phase
    @template = @phase.template
    @current_tab = params[:r] || 'all-templates'
    @base_template_org = @phase.template.base_org
  end


  #add a new phase to a passed template
  def admin_add
    @template = Template.find(params[:id])
    @phase = Phase.new
    @phase.template = @template
    authorize @phase
    @phase.number = @template.phases.count + 1
    render('/org_admin/templates/container',
      locals: {
        partial_path: 'admin_add',
        template: @template,
        edit: true,
        current_tab: params[:r] || 'all-templates'
      })
  end


  #create a phase
  def admin_create
    @phase = Phase.new(params[:phase])
    authorize @phase

    @phase.description = params["phase-desc"]
    @phase.modifiable = true
    @current_tab = params[:r] || 'all-templates'
    if @phase.save
      @phase.template.dirty = true
      @phase.template.save!

      redirect_to admin_show_phase_path(id: @phase.id, r: @current_tab), notice: success_message(_('phase'), _('created'))
    else
      flash[:alert] = failed_create_error(@phase, _('phase'))
      @template = @phase.template
      redirect_to edit_org_admin_template_path(id: @phase.template_id, r: @current_tab)
    end
  end


  #update a phase of a template
  def admin_update
    @phase = Phase.find(params[:id])
    authorize @phase
    
    @phase.description = params["phase-desc"]
    @current_tab = params[:r] || 'all-templates'
    if @phase.update_attributes(params[:phase])
      @phase.template.dirty = true
      @phase.template.save!

      redirect_to admin_show_phase_path(@phase, r: @current_tab), notice: success_message(_('phase'), _('saved'))
    else
      @sections = @phase.sections
      @template = @phase.template
      # These params may not be available in this context so they may need
      # to be set to true without the check
      @edit = true
      @open = !params[:section_id].nil?
      @section_id = (params[:section_id].nil? ? nil : params[:section_id].to_i)
      @question_id = (params[:question_id].nil? ? nil : params[:question_id].to_i)
      flash[:alert] = failed_update_error(@phase, _('phase'))
      if @phase.template.customization_of.present?
        @original_org = Template.where(dmptemplate_id: @phase.template.customization_of).first.org
      else
        @original_org = @phase.template.org
      end
      redirect_to admin_show_phase_path(@phase, r: @current_tab)
    end
  end

  #delete a phase
  def admin_destroy
    @phase = Phase.find(params[:phase_id])
    authorize @phase
    @template = @phase.template
    @current_tab = params[:r] || 'all-templates'
    if @phase.destroy
      @template.dirty = true
      @template.save!

      redirect_to edit_org_admin_template_path(@template, r: @current_tab), notice: success_message(_('phase'), _('deleted'))
    else
      @sections = @phase.sections

      # These params may not be available in this context so they may need
      # to be set to true without the check
      @edit = true
      @open = !params[:section_id].nil?
      @section_id = (params[:section_id].nil? ? nil : params[:section_id].to_i)
      @question_id = (params[:question_id].nil? ? nil : params[:question_id].to_i)
      flash[:alert] = failed_destroy_error(@phase, _('phase'))
      if @phase.template.customization_of.present?
        @original_org = Template.where(dmptemplate_id: @phase.template.customization_of).first.org
      else
        @original_org = @phase.template.org
      end
      redirect_to admin_show_phase_path(@phase, r: @current_tab)
    end
  end
end
