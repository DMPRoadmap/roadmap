class QuestionsController < ApplicationController
  respond_to :html
  after_action :verify_authorized

  #create a question
  def admin_create
    begin
      @question = Question.new(question_params)
      authorize @question
      @question.modifiable = true
      current_tab = params[:r] || 'all-templates'
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
        redirect_to admin_show_phase_path(id: @question.section.phase_id, section_id: @question.section_id, question_id: @question.id, r: current_tab), notice: success_message(_('question'), _('created'))
      else
        @edit = (@question.section.phase.template.org == current_user.org)
        @open = true
        @phase = @question.section.phase
        @section = @question.section
        @sections = @phase.sections
        @section_id = @question.section.id
        @question_id = @question.id

        flash[:alert] = failed_create_error(@question, _('question'))
        if @phase.template.customization_of.present?
          @original_org = Template.where(dmptemplate_id: @phase.template.customization_of).first.org
        else
          @original_org = @phase.template.org
        end
        redirect_to admin_show_phase_path(id: @question.section.phase_id, section_id: @question.section_id, r: current_tab)
      end
    rescue ActionController::ParameterMissing => e
      flash[:alert] = e.message
    end
  end

  #update a question of a template
  def admin_update
    @question = Question.find(params[:id])
    authorize @question

    guidance = @question.get_guidance_annotation(current_user.org_id)
    current_tab = params[:r] || 'all-templates'
    if params["question-guidance-#{params[:id]}"].present?
      unless guidance.present?
        guidance = Annotation.new(type: :guidance, org_id: current_user.org_id, question_id: @question.id)
      end
      guidance.text = params["question-guidance-#{params[:id]}"]
      guidance.save
    else
      # The user cleared out the guidance value so delete the record
      guidance.destroy! if guidance.present?
    end
    example_answer = @question.get_example_answers(current_user.org_id).first
    if params["question"]["annotations_attributes"].present? && params["question"]["annotations_attributes"]["0"]["id"].present?
      unless example_answer.present?
        example_answer = Annotation.new(type: :example_answer, org_id: current_user.org_id, question_id: @question.id)
      end
      example_answer.text = params["question"]["annotations_attributes"]["0"]["text"]
      example_answer.save
    else
      # The user cleared out the example answer value so delete the record
      example_answer.destroy if example_answer.present?
    end    
    
    if @question.question_format.textfield?
      @question.default_value = params["question-default-value-textfield"]
    elsif @question.question_format.textarea?
      @question.default_value = params["question-default-value-textarea"]
    end
    @section = @question.section
    @phase = @section.phase
    template = @phase.template
    
    attrs = params[:question]
    attrs[:theme_ids] = [] unless attrs[:theme_ids]
    
    if @question.update_attributes(attrs)
      @phase.template.dirty = true
      @phase.template.save!

      redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id, question_id: @question.id, r: current_tab), notice: success_message(_('question'), _('saved'))
    else
      @edit = (@phase.template.org == current_user.org)
      @open = true
      @sections = @phase.sections
      @section_id = @section.id
      @question_id = @question.id

      flash[:alert] = failed_update_error(@question, _('question'))
      if @phase.template.customization_of.present?
        @original_org = Template.where(dmptemplate_id: @phase.template.customization_of).first.org
      else
        @original_org = @phase.template.org
      end
      redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id, question_id: @question.id, r: current_tab)
    end
  end

  #delete question
  def admin_destroy
    @question = Question.find(params[:question_id])
    authorize @question
    @section = @question.section
    @phase = @section.phase
    current_tab = params[:r] || 'all-templates'
    if @question.destroy
      @phase.template.dirty = true
      @phase.template.save!

      redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id, r: current_tab), notice: success_message(_('question'), _('deleted'))
    else
      redirect_to admin_show_phase_path(id: @phase.id, section_id: @section.id, r: current_tab), alert: failed_destroy_error(@question, 'question')
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