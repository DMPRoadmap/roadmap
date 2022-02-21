# frozen_string_literal: true

module Dmpopidor
  # rubocop:disable Metrics/ModuleLength
  # Customized code for NotesController
  module NotesController
    # CHANGES
    # Delivered mail contains the name of the collaborator leaving the note
    # Added RESEARCH OUTPUT SUPPORT
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def create
      @note = ::Note.new
      @note.user_id = note_params[:user_id]
      # ensure user has access to plan BEFORE creating/finding answer
      raise Pundit::NotAuthorizedError unless ::Plan.find_by(id: note_params[:plan_id]).readable_by?(@note.user_id)

      ::Answer.transaction do
        @answer = ::Answer.find_by(
          plan_id: note_params[:plan_id],
          question_id: note_params[:question_id],
          research_output_id: note_params[:research_output_id]
        )
        if @answer.blank?
          @answer             = ::Answer.new
          @answer.plan_id     = note_params[:plan_id]
          @answer.question_id = note_params[:question_id]
          @answer.user_id     = @note.user_id
          @answer.research_output_id = note_params[:research_output_id]
          @answer.save!
        end
      end

      @note.answer = @answer
      @note.text = note_params[:text]

      authorize @note

      @plan = @answer.plan
      @research_output = @answer.research_output

      @question = ::Question.find(note_params[:question_id])
      section_id = @question.section_id

      if @note.save
        @status = true
        answer = @note.answer
        plan = answer.plan
        collaborators = plan.users.reject { |u| u == current_user || !u.active }
        deliver_if(recipients: collaborators, key: 'users.new_comment') do |r|
          UserMailer.new_comment(current_user, plan, answer, r).deliver_now
        end
        @notice = success_message(@note, _('created'))
        render(json: {
          'notes' => {
            'id' => note_params[:question_id],
            'html' => render_to_string(partial: 'layout', locals: {
                                         plan: @plan,
                                         question: @question,
                                         answer: @answer,
                                         research_output: @research_output
                                       }, formats: [:html])
          },
          'title' => {
            'id' => note_params[:question_id],
            'html' => render_to_string(partial: 'title', locals: {
                                         answer: @answer
                                       }, formats: [:html])
          },
          'research_output' => {
            'id' => note_params[:research_output_id]
          },
          'section' => {
            'id' => section_id
          }
        }.to_json, status: :created)
      else
        @status = false
        @notice = failure_message(@note, _('create'))
        render json: {
          'msg' => @notice
        }.to_json, status: :bad_request
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # CHANGES
    # Research Output support
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def update
      @note = ::Note.find(params[:id])
      authorize @note
      @note.text = note_params[:text]

      @answer = @note.answer
      @question = @answer.question
      @plan = @answer.plan
      @research_output = @answer.research_output

      question_id = @note.answer.question_id.to_s
      section_id = @question.section_id

      if @note.update(note_params)
        @notice = success_message(@note, _('saved'))
        render(json: {
          'notes' => {
            'id' => question_id,
            'html' => render_to_string(partial: 'layout', locals: {
                                         plan: @plan,
                                         question: @question,
                                         answer: @answer,
                                         research_output: @research_output
                                       }, formats: [:html])
          },
          'title' => {
            'id' => question_id,
            'html' => render_to_string(partial: 'title', locals: {
                                         answer: @answer
                                       }, formats: [:html])
          },
          'research_output' => {
            'id' => @research_output.id
          },
          'section' => {
            'id' => section_id
          }
        }.to_json, status: :ok)
      else
        @notice = failure_message(@note, _('save'))
        render json: {
          'msg' => @notice
        }.to_json, status: :bad_request
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # CHANGES
    # Research Output support
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def archive
      @note = ::Note.find(params[:id])
      authorize @note
      @note.archived = true
      @note.archived_by = params[:note][:archived_by]

      @answer = @note.answer
      @question = @answer.question
      @plan = @answer.plan
      @research_output = @answer.research_output

      question_id = @note.answer.question_id.to_s
      section_id = @question.section_id

      if @note.update(note_params)
        @notice = success_message(@note, _('removed'))
        render(json: {
          'notes' => {
            'id' => question_id,
            'html' => render_to_string(partial: 'layout', locals: {
                                         plan: @plan,
                                         question: @question,
                                         answer: @answer,
                                         research_output: @research_output
                                       }, formats: [:html])
          },
          'title' => {
            'id' => question_id,
            'html' => render_to_string(partial: 'title', locals: {
                                         answer: @answer
                                       }, formats: [:html])
          },
          'research_output' => {
            'id' => @research_output.id
          },
          'section' => {
            'id' => section_id
          }
        }.to_json, status: :ok)
      else
        @notice = failure_message(@note, _('remove'))
        render json: {
          'msg' => @notice
        }.to_json, status: :bad_request
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
  # rubocop:enable Metrics/ModuleLength
end
