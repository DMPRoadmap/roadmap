# frozen_string_literal: true

module OrgAdmin

  class QuestionsController < ApplicationController

    include AllowedQuestionFormats
    include Versionable

    respond_to :html
    after_action :verify_authorized

    def show
      question = Question.includes(:annotations,
                                   :question_options,
                                   section: { phase: :template })
                         .find(params[:id])
      authorize question
      render partial: "show", locals: {
        template: question.section.phase.template,
        section: question.section,
        question: question,
        conditions: question.conditions
      }
    end

    def open_conditions
      question = Question.find(params[:question_id])
      authorize question
      render partial: "org_admin/conditions/container", locals: { question: question, conditions: question.conditions }
    end

    def edit
      question = Question.includes(:annotations,
                                   :question_options,
                                   section: { phase: :template })
                         .find(params[:id])
      authorize question
      render partial: "edit", locals: {
        template: question.section.phase.template,
        section: question.section,
        question: question,
        question_formats: allowed_question_formats,
        conditions: question.conditions
      }
    end

    def new
      section = Section.includes(:questions, phase: :template).find(params[:section_id])
      nbr = section.questions.maximum(:number)
      question_format = QuestionFormat.find_by(title: "Text area")
      question = Question.new(section_id: section.id,
                              question_format: question_format,
                              number: nbr.present? ? nbr + 1 : 1)
      question_formats = allowed_question_formats
      authorize question
      render partial: "form", locals: {
        template: section.phase.template,
        section: section,
        question: question,
        method: "post",
        url: org_admin_template_phase_section_questions_path(
          template_id: section.phase.template.id,
          phase_id: section.phase.id,
          id: section.id),
        question_formats: question_formats
      }
    end

    def create
      question = Question.new(question_params.merge(section_id: params[:section_id]))
      authorize question
      begin
        question = get_new(question)
        section = question.section
        if question.save
          flash[:notice] = success_message(question, _("created"))
        else
          flash[:alert] = failure_message(question, _("create"))
        end
      rescue StandardError => e
        flash[:alert] = _("Unable to create a new version of this template.")
      end
      redirect_to edit_org_admin_template_phase_path(
        template_id: section.phase.template.id,
        id: section.phase.id,
        section: section.id
                  )
    end

    def update
      question = Question.find(params[:id])
      authorize question
      begin
        question = get_modifiable(question)
        # Need to reattach the incoming annotation's and question_options to the
        # modifiable (versioned) question
        attrs = question_params
        attrs = transfer_associations(question) if question.id != params[:id]
        # If the user unchecked all of the themes set the association to an empty array
        # add check for number present to ensure this is not just an annotation
        if attrs[:theme_ids].blank? && attrs[:number].present?
          attrs[:theme_ids] = []
        end
        if question.update(attrs)
          question.update_conditions(params["conditions"])
          flash[:notice] = success_message(question, _("updated"))
        else
          flash[:alert] = flash[:alert] = failure_message(question, _("update"))
        end
      rescue StandardError => e
        puts e.message
        flash[:alert] = _("Unable to create a new version of this template.")
      end
      if question.section.phase.template.customization_of.present?
        redirect_to org_admin_template_phase_path(
          template_id: question.section.phase.template.id,
          id: question.section.phase.id,
          section: question.section.id
        )
      else
        redirect_to edit_org_admin_template_phase_path(
          template_id: question.section.phase.template.id,
          id: question.section.phase.id,
          section: question.section.id
        )
      end
    end

    def destroy
      question = Question.find(params[:id])
      authorize question
      begin
        question = get_modifiable(question)
        section = question.section
        if question.destroy!
          flash[:notice] = success_message(question, _("deleted"))
        else
          flash[:alert] = flash[:alert] = failure_message(question, _("delete"))
        end
      rescue StandardError => e
        flash[:alert] = _("Unable to create a new version of this template.")
      end
      redirect_to edit_org_admin_template_phase_path(
        template_id: section.phase.template.id,
        id: section.phase.id,
        section: section.id
      )
    end

    private

    def question_params
      params.require(:question)
            .permit(:number, :text, :question_format_id, :option_comment_display,
                    :default_value,
                    question_options_attributes: %i[id number text is_default _destroy],
                    annotations_attributes: %i[id text org_id org type _destroy],
                    theme_ids: [])
    end

    # When a template gets versioned by changes to one of its questions we need to loop
    # through the incoming params and ensure that the annotations and question_options
    # get attached to the new question
    def transfer_associations(question)
      attrs = question_params
      if attrs[:annotations_attributes].present?
        attrs[:annotations_attributes].each_key do |key|
          old_annotation = question.annotations.select do |a|
            a.org_id.to_s == attrs[:annotations_attributes][key][:org_id] &&
              a.type.to_s == attrs[:annotations_attributes][key][:type]
          end
          unless old_annotation.empty?
            attrs[:annotations_attributes][key][:id] = old_annotation.first.id
          end
        end
      end
      # TODO: This question_options id swap feel fragile. We cannot really match on any
      # of the data elements because the user may have changed them so we rely on its
      # position within the array/query since they should be equivalent.
      if attrs[:question_options_attributes].present?
        attrs[:question_options_attributes].each_key do |key|
          next unless question.question_options[key.to_i].present?
          hash      = attrs.dig(:question_options_attributes, key)
          hash[:id] = question.question_options[key.to_i].id.to_s
        end
      end
      attrs
    end

  end

end
