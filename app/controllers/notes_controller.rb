class NotesController < ApplicationController
  after_action :verify_authorized

  # POST /notes
  def create
    @note = Note.new(params[:new_note])
    @note.text = params["#{params[:new_note][:question_id]}new_note_text"]
    @note.question_id = params[:new_note][:question_id]
    @note.user_id = params[:new_note][:user_id]
    @note.plan_id = params[:new_note][:plan_id]
    authorize @note

    @plan = Plan.find(@note.plan_id)
    @project = Project.find(@plan.project_id)

    respond_to do |format|
      if @note.save
        session[:question_id_notes] = @note.question_id
        format.html { redirect_to edit_project_plan_path(@project, @plan), status: :found, notice: I18n.t("helpers.comments.note_created") }
      end
    end
  end

  # PUT /notes/1
  def update
    @note = Note.find(params[:note][:id])
    authorize @note
    @note.text = params["#{params[:note][:id]}_note_text"]

    @plan = Plan.find(@note.plan_id)
    @project = Project.find(@plan.project_id)

    respond_to do |format|
      if @note.update_attributes(params[:note])
        session[:question_id_notes] = @note.question_id
        format.html { redirect_to edit_project_plan_path(@project, @plan), status: :found, notice: I18n.t("helpers.comments.note_updated") }
      end
    end
  end

  # ARCHIVE /notes/1
  def archive
    @note = Note.find(params[:note][:id])
    authorize @note
    @note.archived = true
    @note.archived_by = params[:note][:archived_by]

    @plan = Plan.find(@note.plan_id)
    @project = Project.find(@plan.project_id)

    respond_to do |format|
      if @note.update_attributes(params[:note])
        session[:question_id_notes] = @note.question_id
        format.html { redirect_to edit_project_plan_path(@project, @plan), status: :found, notice: I18n.t("helpers.comments.note_removed") }
      end
    end
  end


end
