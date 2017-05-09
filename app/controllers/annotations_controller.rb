class AnnotationsController < ApplicationController
  respond_to :html
  after_action :verify_authorized

  #create suggested answers
  def admin_create
    @suggested_answer = Annotation.new(params[:suggested_answer])
    authorize @suggested_answer
    if @suggested_answer.save
      redirect_to admin_show_phase_path(id: @suggested_answer.question.section.phase_id, section_id: @suggested_answer.question.section_id, question_id: @suggested_answer.question.id, edit: 'true'), notice: _('Information was successfully created.')
    else
      @phase = @suggested_answer.question.section.phase
      @section = @suggested_answer.question.section
      @open = true
      @sections = @phase.sections
      @section_id = @section.id
      @question_id = @suggested_answer.question
      flash[:notice] = failed_create_error(@suggested_answer, _('suggested answer'))
      render "phases/admin_show"
    end
  end


  #update a suggested answer of a template
  def admin_update
    @suggested_answer = SuggestedAnswer.includes(question: { section: {phase: :template}}).find(params[:id])
    authorize @suggested_answer #.question.section.phase.template
    @question = @suggested_answer.question
    @section = @question.section
    @phase = @section.phase
    if @suggested_answer.update_attributes(params[:suggested_answer])
      redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id, question_id: @question.id, edit: 'true'), notice: _('Information was successfully updated.')
    else
      flash[:notice] = failed_update_error(@suggested_answer, _('suggested answer'))
      render action: "phases/admin_show"
    end
  end

  #delete a suggested answer
  def admin_destroy
    @suggested_answer = SuggestedAnswer.includes(question: { section: {phase: :template}}).find(params[:id])
    authorize @suggested_answer
    @question = @suggested_answer.question
    @section = @question.section
    @phase = @section.phase
    if @suggested_answer.destroy
      redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id, edit: 'true'), notice: _('Information was successfully deleted.')
    else
      redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id, edit: 'true'), notice: flash[:notice] = failed_destroy_error(@suggested_answer, _('suggested answer'))
    end
  end

end