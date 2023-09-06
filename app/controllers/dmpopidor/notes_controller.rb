# frozen_string_literal: true

module Dmpopidor
  # rubocop:disable Metrics/ModuleLength
  # Customized code for NotesController
  module NotesController
    include Dmpopidor::ErrorHelper

    # CHANGES
    # Delivered mail contains the name of the collaborator leaving the note
    # Added RESEARCH OUTPUT SUPPORT
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def create
      user_id = note_params[:user_id] || current_user.id
      unless user_id.present? && user_id.to_i.positive?
        Rails.logger.error("User id [#{user_id}] is not valid")
        bad_request("User id [#{user_id}] is not valid")
        return
      end

      plan_id = note_params[:plan_id]
      unless plan_id.present? && plan_id.to_i.positive?
        Rails.logger.error("Plan id [#{plan_id}] is not valid")
        bad_request("Plan id [#{plan_id}] is not valid")
        return
      end

      note_text = note_params[:text]
      unless note_text.present? && !note_text.empty?
        Rails.logger.error('Note content cannot be empty')
        bad_request('Note content cannot be empty')
        return
      end

      # ensure user has access to plan BEFORE creating/finding answer
      raise Pundit::NotAuthorizedError unless ::Plan.find_by(id: plan_id).readable_by?(user_id)

      begin
        @note = ::Note.new
        @note.user_id = user_id

        ::Answer.transaction do
          @answer = ::Answer.find_by(
            plan_id: plan_id,
            question_id: note_params[:question_id],
            research_output_id: note_params[:research_output_id]
          )
          if @answer.blank?
            @answer             = ::Answer.new
            @answer.plan_id     = plan_id
            @answer.question_id = note_params[:question_id]
            @answer.user_id     = @note.user_id
            @answer.research_output_id = note_params[:research_output_id]
            @answer.save!
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error(e.backtrace.join("\n"))
        internal_server_error(e.message)
        return
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error(e.backtrace.join("\n"))
        not_found(e.message)
        return
      end

      begin
        @note.answer = @answer
        @note.text = note_text
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error(e.backtrace.join("\n"))
        internal_server_error(e.message)
        return
      end

      begin
        authorize @note
      rescue Pundit::NotAuthorizedError => e
        Rails.logger.error('An error occurred while checking authorisations')
        Rails.logger.error(e.backtrace.join("\n"))
        forbidden
        return
      end

      begin
        @plan = @answer.plan
        @research_output = @answer.research_output

        @question = ::Question.find(note_params[:question_id])

        if @note.save
          @status = true
          answer = @note.answer
          plan = answer.plan
          collaborators = plan.users.reject { |u| u == current_user || !u.active }
          deliver_if(recipients: collaborators, key: 'users.new_comment') do |r|
            ::UserMailer.new_comment(current_user, plan, answer, r).deliver_later
          end
          @notice = success_message(@note, _('created'))
          @updated_note = ::Note.find_by(id: @note.id)
          render json: {
            status: 201,
            message: 'Note created',
            note: @updated_note.as_json(
              include: {
                user: {
                  only: %w[id surname firstname]
                }
              }
            )
          }, status: :created
        else
          @status = false
          @notice = failure_message(@note, _('create'))
          bad_request(@notice)
        end
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error("Question not found: #{e.message}")
        not_found("Question not found: #{e.message}")
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error("Validation error: #{e.message}")
        internal_server_error("Validation error: #{e.message}")
      rescue StandardError => e
        Rails.logger.error("An unexpected error occurred: #{e.message}")
        internal_server_error("An unexpected error occurred: #{e.message}")
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # CHANGES
    # Research Output support
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def update
      node_id = params[:id]

      unless node_id.present? && node_id.to_i.to_s == node_id && node_id.to_i.positive?
        Rails.logger.error("Note id [#{node_id}] is not valid")
        bad_request("Note id [#{node_id}] is not valid")
        return
      end

      begin
        @note = ::Note.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error("Note [#{note_id}] not found")
        Rails.logger.error(e.backtrace.join("\n"))
        not_found('Note not found')
        return
      rescue StandardError => e
        Rails.logger.error('An error occured during retriving note data')
        Rails.logger.error(e.backtrace.join("\n"))
        internal_server_error(e.message)
        return
      end

      unless @note
        Rails.logger.error('Note not found')
        not_found('Note not found')
        return
      end

      begin
        authorize @note
      rescue Pundit::NotAuthorizedError
        Rails.logger.error('An error occurred while checking authorisations')
        forbidden
        return
      end

      begin
        @note.text = note_params[:text]
        @answer = @note.answer
        @question = @answer.question
        @plan = @answer.plan
        @research_output = @answer.research_output
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error('Note not found')
        Rails.logger.error(e.backtrace.join("\n"))
        not_found('Note not found')
        return
      rescue StandardError => e
        Rails.logger.error("An error has occurred while updating the note [#{node_id}] information")
        Rails.logger.error(e.backtrace.join("\n"))
        internal_server_error(e.message)
        return
      end

      begin
        if @note.update(note_params)
          render json: {
            status: 200,
            message: 'Note updated',
            note: @note.as_json(
              include: {
                user: {
                  only: %w[id surname firstname]
                }
              }
            )
          }, status: :ok
          return
        end

        render json: {
          msg: failure_message(@note, _('save'))
        }.to_json, status: :bad_request
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error('An error occurred while rendering response')
        Rails.logger.error(e.backtrace.join("\n"))
        not_found('Note not found')
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error('An error occurred while rendering response')
        Rails.logger.error(e.backtrace.join("\n"))
        internal_server_error(e.message)
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
        render json: { status: 200, message: 'Note removed successsfully', note: @note }, status: :ok

      else
        @notice = failure_message(@note, _('remove'))
        render bad_request(@notice)
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
  # rubocop:enable Metrics/ModuleLength
end
