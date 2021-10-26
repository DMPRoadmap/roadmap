# frozen_string_literal: true

module Dmpopidor

  module OrgAdmin

    module Questions

      # CHANGES
      # Added  MadmpSchema list
      def edit
        question = Question.includes(:annotations,
                                     :question_options,
                                     section: { phase: :template })
                           .find(params[:id])
        madmp_schemas = MadmpSchema.all
        authorize question
        render json: { html: render_to_string(partial: "edit", locals: {
                                                template: question.section.phase.template,
                                                section: question.section,
                                                question: question,
                                                question_formats: allowed_question_formats,
                                                conditions: question.conditions,
                                                madmp_schemas: madmp_schemas
                                              }) }
      end

      # CHANGES
      # Added Structured Data Schema list
      def new
        section = Section.includes(:questions, phase: :template).find(params[:section_id])
        nbr = section.questions.maximum(:number)
        question_format = QuestionFormat.find_by(title: "Text area")
        question = Question.new(section_id: section.id,
                                question_format: question_format,
                                number: nbr.present? ? nbr + 1 : 1)
        question_formats = allowed_question_formats
        madmp_schemas = MadmpSchema.all
        authorize question
        render json: { html: render_to_string(partial: "form", locals: {
                                                template: section.phase.template,
                                                section: section,
                                                question: question,
                                                method: "post",
                                                url: org_admin_template_phase_section_questions_path(
                                                  template_id: section.phase.template.id,
                                                  phase_id: section.phase.id,
                                                  id: section.id
                                                ),
                                                question_formats: question_formats,
                                                madmp_schemas: madmp_schemas
                                              }) }
      end

      # CHANGES
      # Added Structured param
      def question_params
        params.require(:question)
              .permit(:number, :text, :question_format_id, :option_comment_display,
                      :default_value, :madmp_schema_id,
                      question_options_attributes: %i[id number text is_default _destroy],
                      annotations_attributes: %i[id text org_id org type _destroy],
                      theme_ids: [])
      end

    end

  end

end
