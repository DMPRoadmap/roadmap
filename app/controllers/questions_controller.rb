class QuestionsController < ApplicationController
  respond_to :html
  after_action :verify_authorized

  #create a question
  def admin_create
    @question = Question.new(params[:question])
    authorize @question
    @question.guidance = params["new-question-guidance"]
    @question.default_value = params["new-question-default-value"]
    if @question.save!
      redirect_to admin_show_phase_path(id: @question.section.phase_id, section_id: @question.section_id, question_id: @question.id, edit: 'true'), notice: I18n.t('org_admin.templates.created_message')
    else
      render action: "phases/admin_show"
    end
  end

  #update a question of a template
  def admin_update
    @question = Question.find(params[:id])
    authorize @question
    @question.guidance = params["question-guidance-#{params[:id]}"]
    @question.default_value = params["question-default-value-#{params[:id]}"]
    @section = @question.section
    @phase = @section.phase
    if @question.update_attributes(params[:question])
      redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id, question_id: @question.id, edit: 'true'), notice: I18n.t('org_admin.templates.updated_message')
    else
      render action: "phases/admin_show"
    end
  end

  #delete question
  def admin_destroy
    @question = Question.find(params[:question_id])
    authorize @question
    @section = @question.section
    @phase = @section.phase
    @question.destroy
    redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id, edit: 'true'), notice: I18n.t('org_admin.templates.destroyed_message')
  end

end