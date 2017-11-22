class NotesController < ApplicationController
  after_action :verify_authorized
  respond_to :html

  require "pp"

  def create
    @note = Note.new
    user_id = params[:new_note][:user_id]
    @note.user_id = user_id
    question_id = params[:new_note][:question_id]
    plan_id = params[:new_note][:plan_id]

    # create answer if we dont already have one
    answer=nil  # if defined within transaction block, was not accessable after
    # ensure user has access to plan BEFORE creating/finding an answer
    raise Pundit::NotAuthorizedError unless Plan.find(plan_id).readable_by?(user_id)
    Answer.transaction do
      answer = Answer.find_by(question_id: question_id, plan_id: plan_id)
      if answer.blank?
        answer = Answer.new
        answer.plan_id = plan_id
        answer.question_id = question_id
        answer.user_id = user_id
        answer.save!
      end
    end

    @note.answer = answer
    @note.text = params["#{question_id}new_note_text"]

    authorize @note

    @plan = answer.plan
    @answer = answer
    @question = Question.find(question_id)

    if @note.save
      @status = true
      @notice = _('Comment was successfully created.')
    else
      @status = false
      @notice = failed_create_error(@note, _('note'))
    end
    notes = answer.notes.all
    @num_notes = notes.count
  end



  def update
    @note = Note.find(params[:note][:id])
    authorize @note
    @note.text = params["#{params[:note][:id]}_note_text"]

    @answer = @note.answer
    @question = @answer.question
    @plan = @answer.plan

    if @note.update_attributes(params[:note])
      @notice = _('Comment was successfully saved.')
    else
      @notice = failed_update_error(@note, _('note'))
    end
  end



  def archive
    @note = Note.find(params[:note][:id])
    authorize @note
    @note.archived = true
    @note.archived_by = params[:note][:archived_by]

    @answer = @note.answer
    @question = @answer.question
    @plan = @answer.plan

    if @note.update_attributes(params[:note])
      @notice = _('Comment removed.')
    else
      @notice = failed_destroy_error(@note, _('note'))
    end
  end
end
