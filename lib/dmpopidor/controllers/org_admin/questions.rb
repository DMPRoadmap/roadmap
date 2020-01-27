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
        # Question Format should be blank if "structured" is true
        def update
          question = Question.find(params[:id])
          authorize question
          begin
            question = get_modifiable(question)
            # Need to reattach the incoming annotation's and question_options to the
            # modifiable (versioned) question
            attrs = question_params
            attrs = transfer_associations(question) if question.id != params[:id]
            # If the user unchecked all of the themes set the association to an empty array
            # add check for number present to ensure this is not just an annotation
            if attrs[:theme_ids].blank? && attrs[:number].present?
              attrs[:theme_ids] = []
            end
            if attrs[:structured] == "1"
              attrs[:question_format_id] = nil
            else 
              attrs[:structured_data_schema_id] = nil
            end 
            if question.update(attrs)
              flash[:notice] = success_message(question, _("updated"))
            else
              flash[:alert] = flash[:alert] = failure_message(question, _("update"))
            end
          rescue StandardError => e
            puts e.message
            flash[:alert] = _("Unable to create a new version of this template.")
          end
          if question.section.phase.template.customization_of.present?
            redirect_to org_admin_template_phase_path(
              template_id: question.section.phase.template.id,
              id: question.section.phase.id,
              section: question.section.id
            )
          else
            redirect_to edit_org_admin_template_phase_path(
              template_id: question.section.phase.template.id,
              id: question.section.phase.id,
              section: question.section.id
            )
          end
        end

        # CHANGES
        # Added Structured param
        def question_params
          params.require(:question)
                .permit(:number, :text, :question_format_id, :option_comment_display,
                        :default_value, :structured, :structured_data_schema_id,
                        question_options_attributes: %i[id number text is_default _destroy],
                        annotations_attributes: %i[id text org_id org type _destroy],
                        theme_ids: [])
        end
      end
    end
  end
end