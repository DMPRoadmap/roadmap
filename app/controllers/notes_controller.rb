class NotesController < ApplicationController
  after_action :verify_authorized
  respond_to :html

  ##
  # POST /notes
  def create
    @note = Note.new
    user_id = params[:new_note][:user_id]
    @note.user_id = user_id

    answer_id = params[:new_note][:answer_id]
    question_id = params[:new_note][:question_id]
    plan_id = params[:new_note][:plan_id]
    if answer_id.present?
      answer = Answer.find(@note.answer_id)
    else
      answer = Answer.new
      answer.plan_id = plan_id
      answer.question_id = question_id
      answer.user_id = user_id
      answer.save!
    end

    @note.answer= answer
    @note.text = params["#{params[:new_note][:answer_id]}new_note_text"]

    authorize @note

    @plan = answer.plan
    @phase = answer.question.section.phase

    if @note.save
      session[:question_id_notes] = answer.question_id
      redirect_to edit_plan_phase_path(@plan, @phase), status: :found, notice: _('Comment was successfully created.')
    end
  end

  ##
  # PUT /notes/1
  def update
    @note = Note.find(params[:note][:id])
    authorize @note
    @note.text = params["#{params[:note][:id]}_note_text"]

    @plan = Plan.find(@note.plan_id)
    @project = Project.find(@plan.project_id)

    if @note.update_attributes(params[:note])
      session[:question_id_notes] = @note.question_id
      redirect_to edit_project_plan_path(@project, @plan), status: :found, notice: _('Comment was successfully updated.')
    end
  end

  ##
  # ARCHIVE /notes/1
  def archive
    @note = Note.find(params[:note][:id])
    authorize @note
    @note.archived = true
    @note.archived_by = params[:note][:archived_by]

    @plan = Plan.find(@note.plan_id)
    @project = Project.find(@plan.project_id)

    if @note.update_attributes(params[:note])
      session[:question_id_notes] = @note.question_id
      redirect_to edit_project_plan_path(@project, @plan), status: :found, notice: _('Comment has been removed.')
    end
  end
end
