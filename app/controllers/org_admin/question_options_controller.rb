# frozen_string_literal: true

module OrgAdmin

  class QuestionOptionsController < ApplicationController

    include Versionable

    after_action :verify_authorized

    # rubocop:disable Metrics/AbcSize
    def destroy
      question_option = QuestionOption.find(params[:id])
      option_id_to_remove = question_option.id.to_s
      authorize question_option
      begin
        question_option = get_modifiable(question_option)
        question = question_option.question
        section = question.section
        if question_option.destroy!
          # need to remove any conditions which refer to this question option
          question.conditions.each do |cond|
            cond.destroy if cond.option_list.include?(option_id_to_remove)
          end
          flash[:notice] = success_message(question_option, _("deleted"))
        else
          flash[:alert] = flash[:alert] = failure_message(question_option, _("delete"))
        end
      rescue StandardError
        flash[:alert] = _("Unable to create a new version of this template.")
      end
      redirect_to edit_org_admin_template_phase_path(
        template_id: section.phase.template.id,
        id: section.phase.id,
        section: section.id
      )
    end
    # rubocop:enable Metrics/AbcSize

  end

end
