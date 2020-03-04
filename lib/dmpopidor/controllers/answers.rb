module Dmpopidor
  module Controllers
    module Answers
      # Added Research outputs support
      def create_or_update
        p_params = permitted_params()

        # First it is checked plan exists and question exist for that plan
        begin
          p = Plan.find(p_params[:plan_id])
          if !p.question_exists?(p_params[:question_id])
            # rubocop:disable LineLength
            render(status: :not_found, json: {
              msg: _("There is no question with id %{question_id} associated to plan id %{plan_id} for which to create or update an answer") % {
                question_id: p_params[:question_id],
                plan_id: p_params[:plan_id]
              }
            })
            # rubocop:enable LineLength
            return
        end
        rescue ActiveRecord::RecordNotFound
          # rubocop:disable LineLength
          render(status: :not_found, json: {
            msg: _("There is no plan with id %{id} for which to create or update an answer") % {
              id: p_params[:plan_id]
            }
          })
          # rubocop:enable LineLength
          return
        end
        q = Question.find(p_params[:question_id])

        # rubocop:disable BlockLength
        Answer.transaction do
          begin
            @answer = Answer.find_by!({
                plan_id: p_params[:plan_id], question_id: p_params[:question_id],
                research_output_id: p_params[:research_output_id]
            })
            authorize @answer
            p = p_params.merge(user_id: current_user.id).select { |k, v| !schema_params.include?(k) }
            @answer.update(p)
            if p_params[:question_option_ids].present?
              # Saves the record with the updated_at set to the current time.
              # Needed if only answer.question_options is updated
              @answer.touch()
            end
            if q.question_format.structured
              form_data = p_params.select { |k, v| schema_params.include?(k) }
                s_answer = StructuredAnswer.find_or_initialize_by(answer_id: @answer.id) do |sa|
                  sa.answer = @answer
                  sa.structured_data_schema = q.structured_data_schema
                end
                s_answer.assign_attributes(data: data_reformater(json_schema, form_data))
                s_answer.save
            end
            if q.question_format.rda_metadata?
              @answer.update_answer_hash(
                JSON.parse(params[:standards]), p_params[:text]
              )
              @answer.save!
            end
            rescue ActiveRecord::RecordNotFound
              p = p_params.merge(user_id: current_user.id).select { |k, v| !schema_params.include?(k) }
              @answer = Answer.new(p)
              @answer.lock_version = 1
              authorize @answer
              if q.question_format.structured
                form_data = p_params.select { |k, v| schema_params.include?(k) }
                  s_answer = StructuredAnswer.find_or_initialize_by(answer_id: @answer.id) do |sa|
                    sa.answer = @answer
                    sa.structured_data_schema = q.structured_data_schema
                  end
                  s_answer.assign_attributes(data: data_reformater(json_schema, form_data))
                  s_answer.save
              end
              if q.question_format.rda_metadata?
                @answer.update_answer_hash(
                  JSON.parse(params[:standards]), p_params[:text]
                )
              end
              @answer.save!
              rescue ActiveRecord::StaleObjectError
                @stale_answer = @answer
                @answer = Answer.find_by(
                  plan_id: p_params[:plan_id],
                  question_id: p_params[:question_id]
                )
              end
            end
            # rubocop:enable BlockLength

            if @answer.present?
              @plan = Plan.includes(
                sections: {
                  questions: [
                    :answers,
                    :question_format
                  ]
                }
              ).find(p_params[:plan_id])
              @question = @answer.question
              @section = @plan.sections.find_by(id: @question.section_id)
              template = @section.phase.template
              @research_output = @answer.research_output
              # rubocop:disable LineLength
              render json: {
              "question" => {
                "id" => @question.id,
                "answer_lock_version" => @answer.lock_version,
                "locking" => @stale_answer ?
                  render_to_string(partial: "answers/locking", locals: {
                    question: @question,
                    answer: @stale_answer,
                    research_output: @research_output,
                    user: @answer.user
                  }, formats: [:html]) :
                  nil,
                "form" => render_to_string(partial: "answers/new_edit", locals: {
                  template: template,
                  question: @question,
                  answer: @answer,
                  research_output: @research_output,
                  readonly: false,
                  locking: false,
                  base_template_org: template.base_org
                }, formats: [:html]),
                "answer_status" => render_to_string(partial: "answers/status", locals: {
                  answer: @answer
                }, formats: [:html])
              },
              "section" => {
                "id" => @section.id,
                "progress" => render_to_string(partial: "/org_admin/sections/progress", locals: {
                  section: @section,
                  plan: @plan
                }, formats: [:html])
              },
              "plan" => {
                "id" => @plan.id,
                "progress" => render_to_string(partial: "plans/progress", locals: {
                  plan: @plan,
                  current_phase: @section.phase
                }, formats: [:html])
              },
              "research_output" => {
                "id" => @research_output.id
              }
            }.to_json
            # rubocop:enable LineLength
          end
        end

        private

        def data_reformater(schema, data)
          schema["properties"].each do |key, value|
            case value["type"]
            when "integer"
              data[key] = data[key].to_i
            when "boolean"
              data[key] = data[key] == "1"
            when "array"
              data[key] = data[key].kind_of?(Array) ? data[key] : [data[key]]
            when "object"
              if value["dictionnary"]
                data[key] = JSON.parse(DictionnaryValue.where(id: data[key]).select(:id, :uri, :label).take.to_json)
              end
            end
          end
          data
        end

        def permitted_params_from_properties(properties)
            parameters = Array.new
            properties.each do |key, prop|
                if prop["type"] == "array"
                    parameters.append({key => []})
                else
                    parameters.append(key)
                end
            end
            parameters
        end

        def json_schema
          question = Question.find(params['question_id'])

          question.structured_data_schema.schema
        end

        def schema_params
          permitted_params_from_properties(json_schema['properties'])
        end

        def permitted_params
          permitted = params.require(:answer).permit([:id, :text, :plan_id, :user_id,
                                                     :question_id, :lock_version,
                                                     :research_output_id, :is_common,
                                                     question_option_ids: []].append(schema_params))
          # If question_option_ids has been filtered out because it was a
          # scalar value (e.g. radiobutton answer)
          if !params[:answer][:question_option_ids].nil? &&
             !permitted[:question_option_ids].present?
            permitted[:question_option_ids] = [params[:answer][:question_option_ids]]
          end
          if !permitted[:id].present?
            permitted.delete(:id)
          end
          # If no question options has been chosen.
          if params[:answer][:question_option_ids].nil?
              permitted[:question_option_ids] = []
          end
          permitted
        end
      end
    end
  end
