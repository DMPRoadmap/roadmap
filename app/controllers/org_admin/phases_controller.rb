# frozen_string_literal: true

module OrgAdmin

  class PhasesController < ApplicationController

    include Versionable

    after_action :verify_authorized

    # GET /org_admin/templates/:template_id/phases/:id
    # rubocop:disable Metrics/AbcSize
    def show
      phase = Phase.includes(:template, :sections).order(:number).find(params[:id])
      authorize phase
      unless phase.template.latest?
        # rubocop:disable Layout/LineLength
        flash[:notice] = _("You are viewing a historical version of this template. You will not be able to make changes.")
        # rubocop:enable Layout/LineLength
      end
      sections = if phase.template.customization_of? && phase.template.latest?
                   # The user is working with the latest version so only use the modifiable sections
                   phase.template_sections.order(:number)
                 else
                   # This is not the latest version sso just get all the sections. Everything
                   # will be readonly
                   phase.sections.order(:number)
                 end
      render("container",
             locals: {
               partial_path: "show",
               template: phase.template,
               phase: phase,
               prefix_section: phase.prefix_section,
               sections: sections,
               suffix_sections: phase.suffix_sections.order(:number),
               current_section: Section.find_by(id: params[:section], phase_id: phase.id)
             })
    end
    # rubocop:enable Metrics/AbcSize

    # GET /org_admin/templates/:template_id/phases/:id/edit
    # rubocop:disable Metrics/AbcSize
    def edit
      phase = Phase.includes(:template).find(params[:id])
      authorize phase
      # User cannot edit a phase if its a customization so redirect to show
      if phase.template.customization_of.present? || !phase.template.latest?
        redirect_to org_admin_template_phase_path(
          template_id: phase.template,
          id: phase.id,
          section: params[:section]
        )
      else
        render("container",
               locals: {
                 partial_path: "edit",
                 template: phase.template,
                 phase: phase,
                 prefix_section: phase.prefix_section,
                 sections: phase.sections.order(:number)
                                         .select(:id, :title, :modifiable, :phase_id),
                 suffix_sections: phase.suffix_sections.order(:number),
                 current_section: Section.find_by(id: params[:section], phase_id: phase.id)
               })
      end
    end
    # rubocop:enable Metrics/AbcSize

    # preview a phase
    # GET /org_admin/templates/:template_id/phases/:id/preview
    def preview
      @phase = Phase.includes(:template).find(params[:id])
      authorize @phase
      @template = @phase.template
      @guidance_presenter = GuidancePresenter.new(Plan.new(template: @phase.template))
    end

    # add a new phase to a passed template
    # GET /org_admin/templates/:template_id/phases/new
    def new
      template = Template.includes(:phases).find(params[:template_id])
      if template.latest?
        nbr = template.phases.maximum(:number)
        phase = Phase.new(
          template: template,
          modifiable: true,
          number: (nbr.present? ? nbr + 1 : 1)
        )
        authorize phase
        local_referrer = if request.referrer.present?
                           request.referrer
                         else
                           org_admin_templates_path
                         end
        render("/org_admin/templates/container",
               locals: {
                 partial_path: "new",
                 template: template,
                 phase: phase,
                 referrer: local_referrer
               })
      else
        render org_admin_templates_path,
               alert: _("You cannot add a phase to a historical version of a template.")
      end
    end

    # create a phase
    # POST /org_admin/templates/:template_id/phases
    # rubocop:disable Metrics/AbcSize
    def create
      phase = Phase.new(phase_params)
      phase.template = Template.find(params[:template_id])
      authorize phase
      begin
        phase = get_new(phase)
        phase.modifiable = true
        if phase.save
          flash[:notice] = success_message(phase, _("created"))
        else
          flash[:alert] = failure_message(phase, _("create"))
        end
      rescue StandardError => e
        flash[:alert] = _("Unable to create a new version of this template.") + "<br>" + e.message
      end
      if flash[:alert].present?
        redirect_to new_org_admin_template_phase_path(template_id: phase.template.id)
      else
        redirect_to edit_org_admin_template_phase_path(template_id: phase.template.id,
                                                       id: phase.id)
      end
    end
    # rubocop:enable Metrics/AbcSize

    # update a phase of a template
    # PUT /org_admin/templates/:template_id/phases/:id
    def update
      phase = Phase.find(params[:id])
      authorize phase
      begin
        phase = get_modifiable(phase)
        if phase.update(phase_params)
          flash[:notice] = success_message(phase, _("updated"))
        else
          flash[:alert] = failure_message(phase, _("update"))
        end
      rescue StandardError => e
        flash[:alert] = _("Unable to create a new version of this template.") + "<br>" + e.message
      end
      redirect_to edit_org_admin_template_phase_path(template_id: phase.template.id,
                                                     id: phase.id)
    end

    # POST /org_admin/templates/:template_id/phases/:id/sort
    def sort
      @phase = Phase.find(params[:id])
      authorize @phase
      ordering = phase_params[:sort_order] || []
      Section.update_numbers!(ordering, parent: @phase)
      head :ok
    end

    # delete a phase
    # DELETE /org_admin/templates/:template_id/phases/:id
    # rubocop:disable Metrics/AbcSize
    def destroy
      phase = Phase.includes(:template).find(params[:id])
      authorize phase
      begin
        phase = get_modifiable(phase)
        template = phase.template
        if phase.destroy!
          flash[:notice] = success_message(phase, _("deleted"))
        else
          flash[:alert] = failure_message(phase, _("delete"))
        end
      rescue StandardError => e
        flash[:alert] = _("Unable to create a new version of this template.") + "<br>" + e.message
      end

      if flash[:alert].present?
        redirect_to org_admin_template_phase_path(template.id, phase.id)
      else
        redirect_to edit_org_admin_template_path(template)
      end
    end
    # rubocop:enable Metrics/AbcSize

    private

    def phase_params
      params.require(:phase).permit(:title, :description, :number, sort_order: [])
    end

  end

end
