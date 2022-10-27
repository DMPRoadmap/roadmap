# frozen_string_literal: true

# Controller for the Comments section of the Write Plan page
class NotesController < ApplicationController
  include ConditionalUserMailer
  after_action :verify_authorized
  respond_to :html

  # POST /notes
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def create
    @note = Note.new
    # take user id from current user rather than form as form can be spoofed
    @note.user_id = current_user.id
    # ensure user has access to plan BEFORE creating/finding answer
    raise Pundit::NotAuthorizedError unless Plan.find_by(id: note_params[:plan_id]).readable_by?(@note.user_id)

    Answer.transaction do
      @answer = Answer.find_by(
        plan_id: note_params[:plan_id],
        question_id: note_params[:question_id]
      )
      if @answer.blank?
        @answer             = Answer.new
        @answer.plan_id     = note_params[:plan_id]
        @answer.question_id = note_params[:question_id]
        @answer.user_id     = @note.user_id
        @answer.save!
      end
    end

    @note.answer = @answer
    @note.text = note_params[:text]
    authorize @note

    @plan = @answer.plan
    @question = Question.find(note_params[:question_id])

    if @note.save
      @status = true
      answer = @note.answer
      plan = answer.plan
      owner = plan.owner
      deliver_if(recipients: owner, key: 'users.new_comment') do |_r|
        UserMailer.new_comment(current_user, plan, answer).deliver_now
      end
      @notice = success_message(@note, _('created'))
      render(json: {
        'notes' => {
          'id' => note_params[:question_id],
          'html' => render_to_string(partial: 'layout', locals: {
                                       plan: @plan,
                                       question: @question,
                                       answer: @answer
                                     }, formats: [:html])
        },
        'title' => {
          'id' => note_params[:question_id],
          'html' => render_to_string(partial: 'title', locals: {
                                       answer: @answer
                                     }, formats: [:html])
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

  # PUT /notes/:id
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def update
    @note = Note.find(params[:id])
    authorize @note
    @note.text = note_params[:text]

    @answer = @note.answer
    @question = @answer.question
    @plan = @answer.plan

    question_id = @note.answer.question_id.to_s

    if @note.update(note_params)
      @notice = success_message(@note, _('saved'))
      render(json: {
        'notes' => {
          'id' => question_id,
          'html' => render_to_string(partial: 'layout', locals: {
                                       plan: @plan,
                                       question: @question,
                                       answer: @answer
                                     }, formats: [:html])
        },
        'title' => {
          'id' => question_id,
          'html' => render_to_string(partial: 'title', locals: {
                                       answer: @answer
                                     }, formats: [:html])
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

  # TODO: Consider just using the :destroy route
  # PATCH /notes/:id/archive
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def archive
    @note = Note.find(params[:id])
    authorize @note
    @note.archived = true
    @note.archived_by = params[:note][:archived_by]

    @answer = @note.answer
    @question = @answer.question
    @plan = @answer.plan

    question_id = @note.answer.question_id.to_s

    if @note.update(note_params)
      @notice = success_message(@note, _('removed'))
      render(json: {
        'notes' => {
          'id' => question_id,
          'html' => render_to_string(partial: 'layout', locals: {
                                       plan: @plan,
                                       question: @question,
                                       answer: @answer
                                     }, formats: [:html])
        },
        'title' => {
          'id' => question_id,
          'html' => render_to_string(partial: 'title', locals: {
                                       answer: @answer
                                     }, formats: [:html])
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

  private

  def note_params
    params.require(:note)
          .permit(:text, :archived_by, :user_id, :answer_id, :plan_id,
                  :question_id)
  end
end
