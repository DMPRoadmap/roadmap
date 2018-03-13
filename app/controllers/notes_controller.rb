class NotesController < ApplicationController
  include ConditionalUserMailer
  require "pp"
  after_action :verify_authorized
  respond_to :html

  def create
    @note = Note.new
    @note.user_id = params[:note][:user_id]

    # create answer if we don't have one already
    @answer = nil # if defined within the transaction block, was not accessable afterward
    # ensure user has access to plan BEFORE creating/finding answer
    raise Pundit::NotAuthorizedError unless Plan.find(params[:note][:plan_id]).readable_by?(@note.user_id)
    Answer.transaction do
      @answer = Answer.find_by(plan_id: params[:note][:plan_id], question_id: params[:note][:question_id])
      if @answer.blank?
        @answer = Answer.new
        @answer.plan_id = params[:note][:plan_id]
        @answer.question_id = params[:note][:question_id]
        @answer.user_id = @note.user_id
        @answer.save!
      end
    end

    @note.answer = @answer
    @note.text = params[:note][:text]

    authorize @note

    @plan = @answer.plan

    @question = Question.find(params[:note][:question_id])

    if @note.save
      @status = true
      answer = @note.answer
      plan = answer.plan
      owner = plan.owner
      deliver_if(recipients: owner, key: 'users.new_comment') do |r|
        UserMailer.new_comment(current_user, plan).deliver_now()
      end
      @notice = success_message(_('comment'), _('created'))
      render(json: {
        "notes" => {
          "id" => params[:note][:question_id],
          "html" => render_to_string(partial: 'layout', locals: {plan: @plan, question: @question, answer: @answer }, formats: [:html])
        },
        "title" => {
          "id" => params[:note][:question_id],
          "html" => render_to_string(partial: 'title', locals: { answer: @answer}, formats: [:html])
        }
      }.to_json, status: :created)
    else
      @status = false
      @notice = failed_create_error(@note, _('note'))
      render json: {
        "msg" => @notice
      }.to_json, status: :bad_request
    end
  end

  def update
    @note = Note.find(params[:id])
    authorize @note
    @note.text = params[:note][:text]

    @answer = @note.answer
    @question = @answer.question
    @plan = @answer.plan

    question_id = @note.answer.question_id.to_s

    if @note.update_attributes(params[:note])
      @notice = success_message(_('comment'), _('saved'))
      render(json: {
        "notes" => {
          "id" => question_id,
          "html" => render_to_string(partial: 'layout', locals: {plan: @plan, question: @question, answer: @answer }, formats: [:html])
        },
        "title" => {
          "id" => question_id,
          "html" => render_to_string(partial: 'title', locals: { answer: @answer}, formats: [:html])
        }
      }.to_json, status: :ok)
    else
      @notice = failed_update_error(@note, _('note'))
      render json: {
        "msg" => @notice
      }.to_json, status: :bad_request
    end
  end

  def archive
    @note = Note.find(params[:id])
    authorize @note
    @note.archived = true
    @note.archived_by = params[:note][:archived_by]

    @answer = @note.answer
    @question = @answer.question
    @plan = @answer.plan

    question_id = @note.answer.question_id.to_s

    if @note.update_attributes(params[:note])
      @notice = success_message(_('comment'), _('removed'))
      render(json: {
        "notes" => {
          "id" => question_id,
          "html" => render_to_string(partial: 'layout', locals: {plan: @plan, question: @question, answer: @answer }, formats: [:html])
        },
        "title" => {
          "id" => question_id,
          "html" => render_to_string(partial: 'title', locals: { answer: @answer}, formats: [:html])
        }
      }.to_json, status: :ok)
    else
      @notice = failed_destroy_error(@note, _('note'))
      render json: {
        "msg" => @notice
      }.to_json, status: :bad_request
    end
  end
end
