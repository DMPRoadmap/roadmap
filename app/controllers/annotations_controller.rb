class AnnotationsController < ApplicationController
  respond_to :html
  after_action :verify_authorized

  #create annotations
  def admin_create
    # authorize the question (includes to reduce queries)
    @question = Question.includes(section: { phase: :template}).find(params[:question_id])
    authorize @question
    if params[:example_answer_text].present?
      example_answer = init_annotation(params[:example_answer_text], @question, current_user.org, Annotation.types[:example_answer])
    end
    if params[:guidance_text].present?
      guidance = init_annotation(params[:guidance_text], @question, current_user.org, Annotation.types[:guidance])
    end
    # if they dont exist, no requirement for them to be saved
    ex_save = example_answer.present? ? example_answer.save : true
    guid_save = guidance.present? ? guidance.save : true
    @question.section.phase.template.dirty = true

    if ex_save && guid_save
      redirect_to admin_show_phase_path(id: @question.section.phase_id, section_id: @question.section_id, question_id: @question.id, edit: 'true'), notice: _('Information was successfully created.')
    else
      @section = @question.section
      @phase = @section.phase
      @open = true
      @sections = @phase.sections
      @section_id = @section.id
      @question_id = @example_answer.question
      if !ex_save && !guid_save
        flash[:notice] = failed_create_error(example_answer, _('example answer')) + '\n' +
                          failed_create_error(gudiance, _('guidance'))
      elsif !guid_save
        flash[:notice] = failed_create_error(gudiance, _('guidance'))
      elsif !ex_save
        flash[:notice] = failed_create_error(example_answer, _('example answer'))
      end
      render "phases/admin_show"
    end
  end


  #update a example answer of a template
  def admin_update
    @question = Question.includes(section: { phase: :template}).find(params[:question_id])
    if params[:guidance_id].present?
      guidance = Annotation.includes(question: {section: {phase: :template}}).find(params[:guidance_id])
      authorize guidance
    end
    if params[:example_answer_id].present?
      example_answer = Annotation.includes(question: {section: {phase: :template}}).find(params[:example_answer_id])
      authorize example_answer
    end
    verify_authorized
    # if guidance present, update
    if params[:guidance_text].present?
      if guidance.present?
        guidance.text = params[:guidance_text]
      else
        guidance = init_annotation(params[:guidance_text], @question, current_user.org, Annotation.types[:guidance])
      end
    end
    # if example answer present, update
    if params[:example_answer_text].present?
      if example_answer.present?
        example_answer.text = params[:example_answer_text]
      else
        example_answer = init_annotation(params[:example_answer_text], @question, current_user.org, Annotation.types[:example_answer])
      end
    end
    # only required to save if we updated/created one
    ex_save = example_answer.present? ? example_answer.save : true
    guid_save = guidance.present? ? guidance.save : true

    @section = @question.section
    @phase = @section.phase
    @phase.template.dirty = true

    if ex_save && guid_save
      redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id, question_id: @question.id, edit: 'true'), notice: _('Information was successfully updated.')
    else
      if !ex_save && !guid_save
        flash[:notice] = failed_create_error(example_answer, _('example answer')) + '\n' +
                          failed_create_error(gudiance, _('guidance'))
      elsif !guid_save
        flash[:notice] = failed_create_error(gudiance, _('guidance'))
      elsif !ex_save
        flash[:notice] = failed_create_error(example_answer, _('example answer'))
      end
      render action: "phases/admin_show"
    end
  end

  #delete an annotation
  def admin_destroy
    @example_answer = Annotation.includes(question: { section: {phase: :template}}).find(params[:id])
    authorize @example_answer
    @question = @example_answer.question
    @section = @question.section
    @phase = @section.phase
    @phase.template.dirty = true
    if @example_answer.destroy
      redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id, edit: 'true'), notice: _('Information was successfully deleted.')
    else
      redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id, edit: 'true'), notice: flash[:notice] = failed_destroy_error(@example_answer, _('example answer'))
    end
  end

  private

  def init_annotation(text, question, org, type)
    annotation = Annotation.new
    annotation.org = org
    annotation.question = question
    annotation.text = text
    annotation.type = type
    return annotation
  end

end
