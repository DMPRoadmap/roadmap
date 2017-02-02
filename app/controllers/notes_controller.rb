class NotesController < ApplicationController
  after_action :verify_authorized
  respond_to :html

  ##
  # POST /notes
  def create
    @note = Note.new
    logger.debug "RAY: into save note"
    @note.user_id = params[:new_note][:user_id]
    @note.answer_id = params[:new_note][:answer_id]
    @note.text = params["#{params[:new_note][:answer_id]}new_note_text"]

    authorize @note

    answer = Answer.find(@note.answer_id)
    @plan = answer.plan
    @phase = answer.question.section.phase

    logger.debug "RAY: saving " + @note.inspect
    if @note.save
      session[:question_id_notes] = answer.question_id
      redirect_to edit_plan_phase_path(@plan, @phase), status: :found, notice: I18n.t("helpers.comments.note_created")
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
      redirect_to edit_project_plan_path(@project, @plan), status: :found, notice: I18n.t("helpers.comments.note_updated")
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
      redirect_to edit_project_plan_path(@project, @plan), status: :found, notice: I18n.t("helpers.comments.note_removed")
    end
  end
end
