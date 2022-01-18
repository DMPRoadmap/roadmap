# frozen_string_literal: true

module OrgAdmin

  class SectionsController < ApplicationController

    include Versionable

    respond_to :html
    after_action :verify_authorized

    # GET /org_admin/templates/[:template_id]/phases/[:phase_id]/sections
    def index
      authorize Section.new
      phase = Phase.includes(:template, :sections).find(params[:phase_id])
      edit = phase.template.latest? &&
             (current_user.can_modify_templates? &&
             (phase.template.org_id == current_user.org_id))
      render partial: "index",
             locals: {
               template: phase.template,
               phase: phase,
               prefix_section: phase.prefix_section,
               sections: phase.sections.order(:number),
               suffix_sections: phase.suffix_sections,
               current_section: phase.sections.first,
               modifiable: edit,
               edit: edit
             }
    end

    # GET /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:id]
    def show
      @section = Section.find(params[:id])
      authorize @section
      @section = Section.includes(questions: %i[annotations question_options])
                        .find(params[:id])
      @template = Template.find(params[:template_id])
      render json: { html: render_to_string(partial: "show",
                                            locals: { template: @template, section: @section }) }
    end

    # GET /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:id]/edit
    def edit
      section = Section.includes(phase: :template,
                                 questions: [:question_options, { annotations: :org }])
                       .find(params[:id])
      authorize section
      # User cannot edit a section if its not modifiable or the template is not the
      # latest redirect to show
      partial_name = if section.modifiable? && section.phase.template.latest?
                       "edit"
                     else
                       "show"
                     end
      render json: { html: render_to_string(partial: partial_name,
                                            locals: {
                                              template: section.phase.template,
                                              phase: section.phase,
                                              section: section
                                            }) }
    end

    # POST /org_admin/templates/[:template_id]/phases/[:phase_id]/sections
    # rubocop:disable Metrics/AbcSize
    def create
      @phase = Phase.find_by(id: params[:phase_id])
      if @phase.nil?
        flash[:alert] =
          _("Unable to create a new section. The phase you specified does not exist.")
        redirect_to edit_org_admin_template_path(template_id: params[:template_id])
        return
      end
      @section = @phase.sections.new(section_params)
      authorize @section
      @section = get_new(@section)
      if @section.save
        flash[:notice] = success_message(@section, _("created"))
        redirect_to edit_org_admin_template_phase_path(
          id: @section.phase_id,
          template_id: @phase.template_id,
          section: @section.id
        )
      else
        flash[:alert] = failure_message(@section, _("create"))
        redirect_to edit_org_admin_template_phase_path(
          template_id: @phase.template_id,
          id: @section.phase_id
        )
      end
    end
    # rubocop:enable Metrics/AbcSize

    # PUT /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:id]
    # rubocop:disable Metrics/AbcSize
    def update
      section = Section.includes(phase: :template).find(params[:id])
      authorize section
      begin
        section = get_modifiable(section)
        if section.update(section_params)
          flash[:notice] = success_message(section, _("saved"))
        else
          flash[:alert] = failure_message(section, _("save"))
        end
      rescue StandardError => e
        flash[:alert] = "#{_("Unable to create a new version of this template.")}<br>#{e.message}"
      end

      redirect_to edit_org_admin_template_phase_path(
        template_id: section.phase.template.id,
        id: section.phase.id, section: section.id
      )
    end
    # rubocop:enable Metrics/AbcSize

    # DELETE /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:id]
    # rubocop:disable Metrics/AbcSize
    def destroy
      section = Section.includes(phase: :template).find(params[:id])
      authorize section
      begin
        section = get_modifiable(section)
        phase = section.phase
        if section.destroy!
          flash[:notice] = success_message(section, _("deleted"))
        else
          flash[:alert] = failure_message(section, _("delete"))
        end
      rescue StandardError => e
        flash[:alert] = "#{_("Unable to create a new version of this template.")}<br/>#{e.message}"
      end

      redirect_to(edit_org_admin_template_phase_path(
                    template_id: phase.template.id,
                    id: phase.id
                  ))
    end
    # rubocop:enable Metrics/AbcSize

    private

    def section_params
      params.require(:section).permit(:title, :description)
    end

  end

end
