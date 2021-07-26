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
                plan_id: p_params[:plan_id],
                question_id: p_params[:question_id],
                research_output_id: p_params[:research_output_id]
            })
            authorize @answer
            pa = p_params.merge(user_id: current_user.id)
            
            @answer.update(pa)
            if p_params[:question_option_ids].present?
              # Saves the record with the updated_at set to the current time.
              # Needed if only answer.question_options is updated
              @answer.touch()
            end
            if q.question_format.rda_metadata?
              @answer.update_answer_hash(
                JSON.parse(params[:standards]), p_params[:text]
              )
              @answer.save!
            end
          rescue ActiveRecord::RecordNotFound
            pa = p_params.merge(user_id: current_user.id)
            @answer = Answer.new(pa)
            @answer.lock_version = 1
            authorize @answer
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
                question_id: p_params[:question_id], 
                research_output_id: p_params[:research_output_id] 
              )
            end
          end
          # rubocop:enable BlockLength

          if @answer.present?
            @plan = Plan.includes(
              sections: {
                questions: [
                  :question_format,
                  answers: :madmp_fragment
                ]
              }
            ).find(p_params[:plan_id])
            @question = @answer.question
            @section = @plan.sections.find_by(id: @question.section_id)
            template = @section.phase.template
            @research_output = @answer.research_output
            
            remove_list_after = remove_list(@plan)

            all_question_ids = @plan.questions.pluck(:id)
            all_answers = @plan.answers
            qn_data = {
              to_show: all_question_ids - remove_list_after,
              to_hide: remove_list_after
            }

            section_data = []
            @plan.sections.each do |section|
              next if section.number < @section.number
              n_qs, n_ans = check_answered(section, qn_data[:to_show], all_answers)
              this_section_info = {
                sec_id: section.id,
                no_qns: num_section_questions(@plan, section),
                no_ans: num_section_answers(@plan, section)
              }
              section_data << this_section_info
            end

            send_webhooks(current_user, @answer)
            # rubocop:disable Metrics/LineLength
            render json: {
              "qn_data": qn_data,
              "section_data": section_data,
              "answer" => {
                "id" => @answer.id
              },
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
      end

      def set_answers_as_common
        answer_ids = params[:answer_ids]
        common_value = params[:is_common]
        Answer.where(id: answer_ids).update_all(is_common: common_value)

        render json: {
          "updated_answers": answer_ids
        }.to_json
      end

      private

      # Get the schema from the question, if any (works for strucutred questions/answers only)
      # TODO: move to global var with before_action trigger + rename accordingly (set_json_schema ?)
      def json_schema
        question = Question.find(params['question_id'])
        question.madmp_schema
      end

      # Get the parameters corresponding to the schema
      def schema_params(data, schema, flat = false)
        s_params = schema.generate_strong_params(flat)
        data.require(:answer).permit(s_params)
      end

      def permitted_params
        permit_arr = [:id, :text, :plan_id, :user_id,
          :question_id, :lock_version,
          :research_output_id, :is_common, :parent_id,
          question_option_ids: []]
        permitted = params.require(:answer).permit(permit_arr.flatten)
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
