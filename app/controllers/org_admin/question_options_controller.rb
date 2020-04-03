# frozen_string_literal: true

module OrgAdmin

  class QuestionOptionsController < ApplicationController

    include Versionable

    after_action :verify_authorized


    def destroy
      question_option = QuestionOption.find(params[:id])
      authorize question_option
#      begin
        question_option = get_modifiable(question_option)
        section = question_option.question.section
        if question_option.destroy!
          flash[:notice] = success_message(question_option, _("deleted"))
        else
          flash[:alert] = flash[:alert] = failure_message(question_option, _("delete"))
        end
#      rescue StandardError => e
#        flash[:alert] = _("Unable to create a new version of this template.")
#      end
#      redirect_to edit_org_admin_template_phase_section_path(
#        template_id: question.section.phase.template.id,
#        phase_id: question.section.phase.id,
#        id: question.section.id
#      )
      redirect_to edit_org_admin_template_phase_path(
        template_id: section.phase.template.id,
        id: section.phase.id,
        section: section.id
      )
    end

  end


end
