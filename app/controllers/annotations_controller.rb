class AnnotationsController < ApplicationController
  respond_to :html
  after_action :verify_authorized

  #create suggested answers
  def admin_create
    @example_answer = Annotation.new(params[:annotation])
    authorize @example_answer
    if @example_answer.save
      redirect_to admin_show_phase_path(id: @example_answer.question.section.phase_id, section_id: @example_answer.question.section_id, question_id: @example_answer.question.id, edit: 'true'), notice: _('Information was successfully created.')
    else
      @section = @example_answer.question.section
      @phase = @section.phase
      @open = true
      @sections = @phase.sections
      @section_id = @section.id
      @question_id = @example_answer.question
      flash[:notice] = failed_create_error(@example_answer, _('example answer'))
      render "phases/admin_show"
    end
  end


  #update a example answer of a template
  def admin_update
    @example_answer = Annotation.includes(question: { section: {phase: :template}}).find(params[:id])
    authorize @example_answer #.question.section.phase.template
    @question = @example_answer.question
    @section = @question.section
    @phase = @section.phase
    if @example_answer.update_attributes(params[:annotation])
      redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id, question_id: @question.id, edit: 'true'), notice: _('Information was successfully updated.')
    else
      flash[:notice] = failed_update_error(@example_answer, _('example answer'))
      render action: "phases/admin_show"
    end
  end

  #delete a suggested answer
  def admin_destroy
    @example_answer = Annotation.includes(question: { section: {phase: :template}}).find(params[:id])
    authorize @example_answer
    @question = @example_answer.question
    @section = @question.section
    @phase = @section.phase
    if @example_answer.destroy
      redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id, edit: 'true'), notice: _('Information was successfully deleted.')
    else
      redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id, edit: 'true'), notice: flash[:notice] = failed_destroy_error(@example_answer, _('example answer'))
    end
  end

end