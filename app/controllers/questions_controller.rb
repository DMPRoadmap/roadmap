class QuestionsController < ApplicationController
  respond_to :html
  after_action :verify_authorized

  #create a question
  def admin_create
    begin
      @question = Question.new(question_params)
      authorize @question
      @question.modifiable = true
      if @question.question_format.textfield?
        @question.default_value = params["question-default-value-textfield"]
      elsif @question.question_format.textarea?
        @question.default_value = params["question-default-value-textarea"]
      end
      if @question.save
        @question.section.phase.template.dirty = true
        @question.section.phase.template.save!
        if params[:example_answer].present?
          example_answer = Annotation.new({question_id: @question.id, org_id: current_user.org_id, text: params[:example_answer], type: Annotation.types[:example_answer]})
          example_answer.save
        end
        if params[:guidance].present?
          guidance = Annotation.new({question_id: @question.id, org_id: current_user.org_id, text: params[:guidance], type: Annotation.types[:guidance]})
          guidance.save
        end
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
        if @phase.template.customization_of.present?
          @original_org = Template.where(dmptemplate_id: @phase.template.customization_of).first.org
        else
          @original_org = @phase.template.org
        end
        render template: 'phases/admin_show'
      end
    rescue ActionController::ParameterMissing => e
      flash[:notice] = e.message
    end
  end

  #update a question of a template
  def admin_update
    @question = Question.find(params[:id])
    authorize @question
    guidance = @question.get_guidance_annotation(current_user.org_id)
    if params["question-guidance-#{params[:id]}"].present?
      if guidance.blank?
        guidance = @question.annotations.build
        guidance.type = :guidance
        guidance.org_id = current_user.org_id
      end
      guidance.text = params["question-guidance-#{params[:id]}"]
      guidance.save
    end
    example_answer = @question.get_example_answer(current_user.org_id)
    if params["question"]["annotations_attributes"].present? && params["question"]["annotations_attributes"]["0"]["id"].present?
      if example_answer.blank?
        example_answer = @question.annotations.build
        example_answer.type = :example_answer
        example_answer.org_id = current_user.org_id
      end
      example_answer.text = params["question"]["annotations_attributes"]["0"]["text"]
      example_answer.save
    end
    if @question.question_format.textfield?
      @question.default_value = params["question-default-value-textfield"]
    elsif @question.question_format.textarea?
      @question.default_value = params["question-default-value-textarea"]
    end
    @section = @question.section
    @phase = @section.phase
    template = @phase.template
    if @question.update_attributes(params[:question])
      @phase.template.dirty = true
      @phase.template.save!

      redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id, question_id: @question.id, edit: 'true'), notice: _('Information was successfully updated.')
    else
      @edit = (@phase.template.org == current_user.org)
      @open = true
      @sections = @phase.sections
      @section_id = @section.id
      @question_id = @question.id

      flash[:notice] = failed_update_error(@question, _('question'))
      if @phase.template.customization_of.present?
        @original_org = Template.where(dmptemplate_id: @phase.template.customization_of).first.org
      else
        @original_org = @phase.template.org
      end
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

  private
    # Filters the valid attributes for a question according to each type.
    # Note, that params[:question] and params[:question][:question_format_id] are required and their absence raises ActionController::ParameterMissing
    def question_params
      permitted = params.require(:question).except(:created_at, :updated_at).tap do |question_params|
        question_params.require(:question_format_id)
        q_format = QuestionFormat.find(question_params[:question_format_id])
        if !q_format.option_based?
          question_params.delete(':question_options_attributes')
        end
      end
    end
end