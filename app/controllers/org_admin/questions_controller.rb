module OrgAdmin
  class QuestionsController < ApplicationController
    include Versionable
  
    respond_to :html
    after_action :verify_authorized

    # GET /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:section_id]/questions
    def index
      authorize Question.new
      section = Section.includes(:questions, phase: :template).find(params[:section_id])
      editing = (current_user.can_modify_templates?  &&  (section.phase.template.org_id == current_user.org_id))
# TODO: refactor so we're only sending back what is necessary
      render partial: 'index', 
        locals: { 
          template: section.phase.template, 
          phase: section.phase, 
          section: section,
          questions: section.questions, 
          current_tab: params[:r] || 'all-templates',
          editing: editing 
        }
    end

    # POST /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:section_id]/questions
    def create
      question = Question.new(question_params.merge({ section_id: params[:section_id] }))
      authorize question
      section = Section.includes(:questions, phase: :template).find(params[:section_id])
      begin
        question = get_new(question)
        section = question.section
        
        if question.save!
          flash[:notice] = success_message(_('question'), _('created'))
        else
          flash[:alert] = failed_create_error(question, _('question'))
        end
      rescue StandardError => e
        flash[:alert] = _('Unable to create a new version of this template.')
      end
      redirect_to edit_org_admin_template_phase_path(template_id: section.phase.template.id, id: section.phase.id, section: section.id)
    end

    # PUT /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:section_id]/questions/[:id]
    def update
      question = Question.find(params[:id])
      authorize question
      begin
        question = get_modifiable(question)
        if question.update!(question_params)
          flash[:notice] = success_message(_('question'), _('updated'))
        else
          flash[:alert] = failed_update_error(question, _('question'))
        end
      rescue StandardError => e
        flash[:alert] = _('Unable to create a new version of this template.')
      end        
      redirect_to edit_org_admin_template_phase_path({
        template_id: question.section.phase.template.id, 
        id: question.section.phase.id, 
        section: question.section.id
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
      redirect_to edit_org_admin_template_phase_path({
        template_id: question.section.phase.template.id, 
        id: question.section.phase.id, 
        section: question.section.id
      })
    end

    private
      def question_params
        params.require(:question).permit(:number, :text, :question_format_id, :option_comment_display, :default_value, question_options_attributes: [:id, :number, :text, :is_default, :_destroy], annotations_attributes: [:id, :text, :org_id, :org, :type], theme_ids: [])
      end
  end
end