class QuestionsController < ApplicationController
  respond_to :html
  after_action :verify_authorized

  #create a question
  def admin_create
    @question = Question.new(params[:question])
    authorize @question
    @question.guidance = params["new-question-guidance"]
    @question.default_value = params["new-question-default-value"]
    if @question.save
      @question.section.phase.template.dirty = true
      @question.section.phase.template.save!
      
      redirect_to admin_show_phase_path(id: @question.section.phase_id, section_id: @question.section_id, question_id: @question.id, edit: 'true'), notice: _('Information was successfully created.')
    else
      @edit = (@question.section.phase.template.org == current_user.org)
      @open = true
      @phase = @question.section.phase
      @section = @question.section
      @sections = @phase.sections
      @section_id = @question.section.id
      @question_id = @question.id
      
      flash[:notice] = failed_create_error(@question, _('question'))
      render template: 'phases/admin_show'
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
      @question.section.phase.template.dirty = true
      @question.section.phase.template.save!
      
      redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id, question_id: @question.id, edit: 'true'), notice: _('Information was successfully updated.')
    else
      @edit = (@phase.template.org == current_user.org)
      @open = true
      @sections = @phase.sections
      @section_id = @section.id
      @question_id = @question.id
      
      flash[:notice] = failed_update_error(@question, _('question'))
      render template: 'phases/admin_show'
    end
  end

  #delete question
  def admin_destroy
    @question = Question.find(params[:question_id])
    authorize @question
    @section = @question.section
    @phase = @section.phase
    if @question.destroy
      @phase.template.dirty = true
      @phase.template.save!
      
      redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id, edit: 'true'), notice: _('Information was successfully deleted.')
    else
      redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id, edit: 'true'), notice: failed_destroy_error(@question, 'question')
    end
  end

end