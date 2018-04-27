module OrgAdmin
  class QuestionsController < ApplicationController
    include Versionable
  
    respond_to :html
    after_action :verify_authorized

    # GET /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:section_id]/questions
    def index
      authorize Question.new
      section = Section.includes(:questions, phase: :template).find(params[:section_id])
      edit = (current_user.can_modify_templates?  &&  (section.phase.template.org_id == current_user.org_id))
# TODO: refactor so we're only sending back what is necessary
      render partial: 'index', 
        locals: { 
          template: section.phase.template, 
          phase: section.phase, 
          section: section,
          questions: section.questions, 
          current_tab: params[:r] || 'all-templates',
          edit: edit 
        }
    end

    # GET /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:section_id]/questions/[:id]
    def show
      question = Question.find(params[:id])
      authorize question
      question = Question.includes(:annotations, :question_options).find(params[:id])
      render partial: 'show', 
        locals: { 
          template: question.section.phase.template, 
          phase: question.section.phase, 
          section: question.section,
          question: question, 
          original_org: question.section.phase.template.base_org, 
          edit: false 
        }
    end

    # GET /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:section_id]/questions/[:id]/edit
    def edit
      question = Question.find(params[:id])
      authorize question
      question = Question.includes(:annotations, :question_options, section: { phase: :template }).find(params[:id])
# TODO: refactor so we're only sending back what is necessary
      render partial: 'edit', 
        locals: { 
          template: question.section.phase.template, 
          phase: question.section.phase, 
          section: question.section,
          question: question,
          current_tab: params[:r] || 'all-templates',
          edit: true
        }
    end

    # GET /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:section_id]/questions/new
    def new
      section = Section.includes(:questions).find(params[:section_id])
      question = Question.new(section: section, number: (section.questions.length > 0 ? section.questions.max{ |a, b| a.number <=> b.number }.number+1 : 1))
      authorize question
# TODO: refactor so we're only sending back what is necessary
      render partial: 'new', 
        locals: { 
          template: section.phase.template,
          phase: section.phase,
          section: section,
          question: question,
          current_tab: params[:r] || 'all-templates'
        }
    end
    
    # POST /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:section_id]/questions
    def create
      question = Question.new(question_params.merge({ section_id: params[:section_id] }))
      current_tab = params[:r] || 'all-templates'
      authorize question
      section = Section.includes(:questions, phase: :template).find(params[:section_id])
      begin
        question = get_new(question)
        section = question.section
        
# TODO: update UI so that this comes in as part of the `question:` part of the params
        if question.question_format.textfield?
          question.default_value = params["question-default-value-textfield"]
        elsif question.question_format.textarea?
          question.default_value = params["question-default-value-textarea"]
        end

# TODO: Consider calling this via AJAX and returning the `edit` partial instead of rerendering the entire page
        if question.save!
          flash[:notice] = success_message(_('question'), _('created'))
# TODO: update UI so that this comes in as part of the `question:` part of the params
          # Save any example answer or guidance
          if params[:example_answer].present?
            example_answer = Annotation.new({question_id: question.id, org_id: current_user.org_id, text: params[:example_answer], type: Annotation.types[:example_answer]})
            example_answer.save!
          end
          if params[:guidance].present?
            guidance = Annotation.new({question_id: question.id, org_id: current_user.org_id, text: params[:guidance], type: Annotation.types[:guidance]})
            guidance.save!
          end
        else
          flash[:alert] = failed_create_error(question, _('question'))
        end
      rescue StandardError => e
        flash[:alert] = _('Unable to create a new version of this template.')
      end
# TODO: Update this so we're only passing what we need to the new views
      if flash[:alert].present?
        redirect_to org_admin_template_phase_path(template_id: section.phase.template.id, id: section.phase.id, section_id: section.id, r: current_tab)
      else
        redirect_to org_admin_template_phase_path(template_id: section.phase.template.id, id: section.phase.id, section_id: section.id, question_id: question.id, r: current_tab)
      end
    end

    # PUT /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:section_id]/questions/[:id]
    def update
      question = Question.find(params[:id])
      authorize question

      begin
        question = get_modifiable(question)
        
        guidance = question.get_guidance_annotation(current_user.org_id)
        current_tab = params[:r] || 'all-templates'
        if params["question-guidance-#{params[:id]}"].present?
          unless guidance.present?
            guidance = Annotation.new(type: :guidance, org_id: current_user.org_id, question_id: question.id)
          end
          guidance.text = params["question-guidance-#{params[:id]}"]
          guidance.save
        else
          # The user cleared out the guidance value so delete the record
          guidance.destroy! if guidance.present?
        end
        example_answer = question.get_example_answers(current_user.org_id).first
        if params["question"]["annotations_attributes"].present? && params["question"]["annotations_attributes"]["0"]["id"].present?
          unless example_answer.present?
            example_answer = Annotation.new(type: :example_answer, org_id: current_user.org_id, question_id: question.id)
          end
          example_answer.text = params["question"]["annotations_attributes"]["0"]["text"]
          example_answer.save
        else
          # The user cleared out the example answer value so delete the record
          example_answer.destroy if example_answer.present?
        end
        
        if question.question_format.textfield?
          question.default_value = params["question-default-value-textfield"]
        elsif question.question_format.textarea?
          question.default_value = params["question-default-value-textarea"]
        end
          
# TODO: Update to use question_params which is more secure
        attrs = params[:question]
        attrs[:theme_ids] = [] unless attrs[:theme_ids]
        
        if question.update!(attrs)
          flash[:notice] = success_message(_('question'), _('updated'))
        else
          flash[:alert] = failed_update_error(question, _('question'))
        end
      rescue StandardError => e
        flash[:alert] = _('Unable to create a new version of this template.')
      end        
# TODO: Update this so we're only passing what we need to the new views
      redirect_to org_admin_template_phase_path({
        template_id: question.section.phase.template.id, 
        id: question.section.phase.id, 
        section_id: question.section.id, 
        question_id: question.id, 
        r: current_tab
      })
    end

    # DELETE /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:section_id]/questions/[:id]
    def destroy
      question = Question.find(params[:id])
      authorize question
      begin
        question = get_modifiable(question)
        current_tab = params[:r] || 'all-templates'
        if question.destroy!
          flash[:notice] = success_message(_('question'), _('deleted'))
        else
          flash[:alert] = failed_destroy_error(question, 'question')
        end
      rescue StandardError => e
        flash[:alert] = _('Unable to create a new version of this template.')
      end
# TODO: Update this so we're only passing what we need to the new views
      redirect_to org_admin_template_phase_path({
        template_id: question.section.phase.template.id, 
        id: question.section.phase.id, 
        section_id: question.section.id, 
        r: current_tab
      })
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
end