# frozen_string_literal: true

module Dmpopidor
  # rubocop:disable Metrics/ModuleLength
  # Customized code for AnswersController
  module AnswersController
    include Dmpopidor::ErrorHelper

    # Added Research outputs support
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def create_or_update
      p_params = permitted_params

      # First it is checked plan exists and question exist for that plan
      begin
        p = ::Plan.find(p_params[:plan_id])
        unless p.question_exists?(p_params[:question_id])
          # rubocop:disable Layout/LineLength
          render(status: :not_found, json: {
                   msg: format(_('There is no question with id %{question_id} associated to plan id %{plan_id} for which to create or update an answer'), question_id: p_params[:question_id], plan_id: p_params[:plan_id])
                 })
          # rubocop:enable Layout/LineLength
          return
        end
      rescue ActiveRecord::RecordNotFound
        render(status: :not_found, json: {
                 msg: format(_('There is no plan with id %{id} for which to create or update an answer'),
                             id: p_params[:plan_id])
               })
        return
      end
      q = ::Question.find(p_params[:question_id])

      # rubocop:disable Metrics/BlockLength
      ::Answer.transaction do
        args = p_params
        # Answer model does not understand :standards so remove it from the params
        standards = args[:standards]
        args.delete(:standards)

        @answer = ::Answer.find_by!(
          plan_id: args[:plan_id],
          question_id: args[:question_id],
          research_output_id: args[:research_output_id]
        )
        authorize @answer

        @answer.update(args.merge(user_id: current_user.id))
        if args[:question_option_ids].present?
          # Saves the record with the updated_at set to the current time.
          # Needed if only answer.question_options is updated
          @answer.touch
        end
        if q.question_format.rda_metadata?
          @answer.update_answer_hash(
            JSON.parse(standards.to_json), args[:text]
          )
          @answer.save!
        end
      rescue ActiveRecord::RecordNotFound
        @answer = ::Answer.new(args.merge(user_id: current_user.id))
        @answer.lock_version = 1
        authorize @answer
        if q.question_format.rda_metadata?
          @answer.update_answer_hash(
            JSON.parse(standards.to_json), args[:text]
          )
        end
        @answer.save!
      rescue ActiveRecord::StaleObjectError
        @stale_answer = @answer
        @answer = ::Answer.find_by(
          plan_id: args[:plan_id],
          question_id: args[:question_id],
          research_output_id: args[:research_output_id]
        )
      end
      # rubocop:enable Metrics/BlockLength

      # TODO: Seems really strange to do this check. If its false it returns an
      #      200 with an empty body. We should update to send back some JSON. The
      #      check should probably happen on create/update
      # rubocop:disable Style/GuardClause
      if @answer.present?
        @plan = ::Plan.includes(
          sections: {
            questions: %i[
              answers
              question_format
            ]
          }
        ).find(p_params[:plan_id])
        @question = @answer.question
        @section = @plan.sections.find_by(id: @question.section_id)
        template = @section.phase.template
        @research_output = @answer.research_output

        remove_list_after = remove_list(@plan)

        all_question_ids = @plan.questions.pluck(:id)
        # rubocop pointed out that these variable is not used
        # all_answers = @plan.answers
        qn_data = {
          to_show: all_question_ids - remove_list_after,
          to_hide: remove_list_after
        }

        section_data = []
        @plan.sections.each do |section|
          next if section.number < @section.number

          # rubocop pointed out that these variables are not used
          # n_qs, n_ans = check_answered(section, qn_data[:to_show], all_answers)
          this_section_info = {
            sec_id: section.id,
            no_qns: num_section_questions(@plan, section),
            no_ans: num_section_answers(@plan, section)
          }
          section_data << this_section_info
        end

        send_webhooks(current_user, @answer)
        render json: {
          qn_data: qn_data,
          section_data: section_data,
          'answer' => {
            'id' => @answer.id
          },
          'question' => {
            'id' => @question.id,
            'answer_lock_version' => @answer.lock_version,
            'locking' => if @stale_answer
                           render_to_string(partial: 'answers/locking', locals: {
                                              question: @question,
                                              answer: @stale_answer,
                                              research_output: @research_output,
                                              user: @answer.user
                                            }, formats: [:html])
                         end,
            'form' => render_to_string(partial: 'answers/new_edit', locals: {
                                         template: template,
                                         question: @question,
                                         answer: @answer,
                                         research_output: @research_output,
                                         readonly: false,
                                         locking: false,
                                         base_template_org: template.base_org
                                       }, formats: [:html]),
            'answer_status' => render_to_string(partial: 'answers/status', locals: {
                                                  answer: @answer
                                                }, formats: [:html])
          },
          'plan' => {
            'id' => @plan.id,
            'progress' => render_to_string(partial: 'plans/progress', locals: {
                                             plan: @plan,
                                             current_phase: @section.phase
                                           }, formats: [:html])
          },
          'research_output' => {
            'id' => @research_output.id
          }
        }.to_json
      end
      # rubocop:enable Style/GuardClause
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def set_answers_as_common
      answer_ids = params[:answer_ids]
      common_value = params[:is_common]
      ::Answer.where(id: answer_ids).update_all(is_common: common_value)

      render json: {
        updated_answers: answer_ids
      }.to_json
    end

    # Public: Retrieves notes associated with a specific answer and includes user information.
    #
    # This method retrieves notes associated with the specified answer and includes information
    # about the users who created the notes. The method performs authorization checks to ensure
    # that the requesting user has the appropriate permissions to access the notes.
    #
    # Parameters:
    #   None
    #
    # Returns:
    #   JSON: A JSON response containing the notes with associated user information.
    #
    # Errors:
    #   - 400 (Bad Request) if the answer_id parameter is missing, not a positive integer, or not provided.
    #   - 404 (Not Found) if the specified answer is not found.
    #   - 403 (Forbidden) if the requesting user is not authorized to access the resource.
    #   - 500 (Internal Server Error) if an unexpected error occurs during processing.
    #
    # Example:
    #   GET /answers/:answer_id/notes
    #
    #   Returns a JSON response with the notes and associated user information.
    def notes
      answer_id = params[:answer_id]

      unless answer_id.present? && answer_id.to_i.positive?
        Rails.logger.error("Answer id [#{answer_id}] is not valid")
        bad_request("Answer id [#{answer_id}] is not valid")
        return
      end

      begin
        @answer = ::Answer.find(answer_id)
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error("Answer [#{answer_id}] not found")
        Rails.logger.error(e.backtrace.join("\n"))
        not_found('No answer found')
        return
      rescue StandardError => e
        Rails.logger.error('An error occured during retriving answer data')
        Rails.logger.error(e.backtrace.join("\n"))
        internal_server_error(e.message)
        return
      end

      unless @answer
        Rails.logger.error('No answer found')
        not_found('No answer found')
        return
      end

      begin
        authorize @answer
      rescue Pundit::NotAuthorizedError => e
        Rails.logger.error('An error occurred while checking authorisations')
        Rails.logger.error(e.backtrace.join("\n"))
        forbidden
        return
      end

      notes_with_users = begin
        @answer.notes
          .where(archived: false)
          .order(created_at: :desc)
          .includes(:user)
          .as_json(
            include: {
              user: {
                only: %w[id surname firstname]
              }
            }
          )
      rescue StandardError => e
        Rails.logger.error('An error occurred while rendering response')
        Rails.logger.error(e.backtrace.join("\n"))
        internal_server_error(e.message)
        return
      end

      render json: { status: 200, message: "#{notes_with_users.length} notes found", notes: notes_with_users }
    end

    private

    # Get the schema from the question, if any (works for strucutred questions/answers only)
    # TODO: move to global var with before_action trigger + rename accordingly (set_json_schema ?)
    def json_schema
      question = ::Question.find(params['question_id'])
      question.madmp_schema
    end

    # Get the parameters corresponding to the schema
    def schema_params(data, schema, flat: false)
      s_params = schema.generate_strong_params(flat: flat)
      data.require(:answer).permit(s_params)
    end

    # rubocop:disable Metrics/AbcSize
    def permitted_params
      permitted = params.require(:answer)
                        .permit(:id, :text, :plan_id, :user_id, :question_id,
                                :research_output_id, :is_common, :parent_id,
                                :lock_version, question_option_ids: [], standards: {})
      # If question_option_ids has been filtered out because it was a
      # scalar value (e.g. radiobutton answer)
      if !params[:answer][:question_option_ids].nil? &&
         !permitted[:question_option_ids].present?
        permitted[:question_option_ids] = [params[:answer][:question_option_ids]]
      end
      permitted.delete(:id) unless permitted[:id].present?
      # If no question options has been chosen.
      permitted[:question_option_ids] = [] if params[:answer][:question_option_ids].nil?
      permitted
    end
    # rubocop:enable Metrics/AbcSize
  end
  # rubocop:enable Metrics/ModuleLength
end
