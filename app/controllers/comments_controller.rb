class CommentsController < ApplicationController
  after_action :verify_authorized

  # POST /comments
  def create
    @comment = Comment.new(params[:new_comment])
    @comment.text = params["#{params[:new_comment][:question_id]}new_comment_text"]
    @comment.question_id = params[:new_comment][:question_id]
    @comment.user_id = params[:new_comment][:user_id]
    @comment.plan_id = params[:new_comment][:plan_id]
    authorize @comment

    @plan = Plan.find(@comment.plan_id)
    @project = Project.find(@plan.project_id)

    respond_to do |format|
      if @comment.save
        session[:question_id_comments] = @comment.question_id
        format.html { redirect_to edit_project_plan_path(@project, @plan), status: :found, notice: I18n.t("helpers.comments.comment_created") }
      end
    end
  end

  # PUT /comments/1
  def update
    @comment = Comment.find(params[:comment][:id])
    authorize @comment
    @comment.text = params["#{params[:comment][:id]}_comment_text"]

    @plan = Plan.find(@comment.plan_id)
    @project = Project.find(@plan.project_id)

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        session[:question_id_comments] = @comment.question_id
        format.html { redirect_to edit_project_plan_path(@project, @plan), status: :found, notice: I18n.t("helpers.comments.comment_updated") }
      end
    end
  end

  # ARCHIVE /comments/1
  # ARCHIVE /comments/1.json
  def archive
    @comment = Comment.find(params[:comment][:id])
    authorize @comment
    @comment.archived = true
    @comment.archived_by = params[:comment][:archived_by]

    @plan = Plan.find(@comment.plan_id)
    @project = Project.find(@plan.project_id)

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        session[:question_id_comments] = @comment.question_id
        format.html { redirect_to edit_project_plan_path(@project, @plan), status: :found, notice: I18n.t("helpers.comments.comment_removed") }
      end
    end
  end


end
