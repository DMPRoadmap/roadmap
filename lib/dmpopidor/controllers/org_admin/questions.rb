module Dmpopidor
  module Controllers
    module OrgAdmin
      module Questions


        # CHANGES
        # Added Structured Data Schema list
        def edit
          question = Question.includes(:annotations,
                                      :question_options,
                                      section: { phase: :template })
                            .find(params[:id])
          structured_data_schemas = StructuredDataSchema.all
          authorize question
          render partial: "edit", locals: {
            template: question.section.phase.template,
            section: question.section,
            question: question,
            question_formats: allowed_question_formats,
            structured_data_schemas: structured_data_schemas
          }
        end


        # CHANGES
        # Added Structured param
        def question_params
          params.require(:question)
                .permit(:number, :text, :question_format_id, :option_comment_display,
                        :default_value, :structured_data_schema_id,
                        question_options_attributes: %i[id number text is_default _destroy],
                        annotations_attributes: %i[id text org_id org type _destroy],
                        theme_ids: [])
        end
      end
    end
  end
end