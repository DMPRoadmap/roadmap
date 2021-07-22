# frozen_string_literal: true

module OrgAdmin

  class QuestionsController < ApplicationController

    include AllowedQuestionFormats
    include Versionable
    include ConditionsHelper

    respond_to :html
    after_action :verify_authorized

    # GET /org_admin/templates/:template_id/phases/:phase_id/sections/:section_id/questions/:id
    def show
      question = Question.includes(:annotations,
                                   :question_options,
                                   section: { phase: :template })
                         .find(params[:id])
      authorize question
      render json: { html: render_to_string(partial: "show", locals: {
                                              template: question.section.phase.template,
                                              section: question.section,
                                              question: question,
                                              conditions: question.conditions
                                            }) }
    end

    # TODO: Shouldn't this live on the conditions controller as :index?
    # GET /org_admin/questions/:question_id/open_conditions
    def open_conditions
      question = Question.find(params[:question_id])
      authorize question
      render json: { container: render_to_string(partial: "org_admin/conditions/container",
                                                 formats: :html,
                                                 layout: false,
                                                 locals: {
                                                   question: question,
                                                   conditions: question.conditions.order(:number)
                                                 }),
                     webhooks: webhook_hash(question.conditions) }
    end

    # rubocop:disable Layout/LineLength
    # GET /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:id]/questions/[:question_id]/edit
    # rubocop:enable Layout/LineLength
    def edit
      question = Question.includes(:annotations,
                                   :question_options,
                                   section: { phase: :template })
                         .find(params[:id])
      authorize question
      render json: { html: render_to_string(partial: "edit", locals: {
                                              template: question.section.phase.template,
                                              section: question.section,
                                              question: question,
                                              question_formats: allowed_question_formats,
                                              conditions: question.conditions
                                            }) }
    end

    # GET /org_admin/templates/:template_id/phases/:phase_id/sections/:section_id/questions/new
    def new
      section = Section.includes(:questions, phase: :template).find(params[:section_id])
      nbr = section.questions.maximum(:number)
      question_format = QuestionFormat.find_by(title: "Text area")
      question = Question.new(section_id: section.id,
                              question_format: question_format,
                              number: nbr.present? ? nbr + 1 : 1)
      question_formats = allowed_question_formats
      authorize question
      render json: { html: render_to_string(partial: "form", locals: {
                                              template: section.phase.template,
                                              section: section,
                                              question: question,
                                              method: "post",
                                              url: org_admin_template_phase_section_questions_path(
                                                template_id: section.phase.template.id,
                                                phase_id: section.phase.id,
                                                id: section.id
                                              ),
                                              question_formats: question_formats
                                            }) }
    end

    # POST /org_admin/templates/:template_id/phases/:phase_id/sections/:section_id/questions
    # rubocop:disable Metrics/AbcSize
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
      rescue StandardError
        flash[:alert] = _("Unable to create a new version of this template.")
      end
      redirect_to edit_org_admin_template_phase_path(
        template_id: section.phase.template.id,
        id: section.phase.id,
        section: section.id
      )
    end
    # rubocop:enable Metrics/AbcSize

    # PUT /org_admin/templates/:template_id/phases/:phase_id/sections/:section_id/questions/:id
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def update
      question = Question.find(params[:id])
      authorize question

      new_version = question.template.generate_version?

      old_question_ids = {}
      if new_version
        # get a map from option number to id
        old_number_to_id = {}
        question.question_options.each do |opt|
          old_number_to_id[opt.number] = opt.id
        end

        # get a map from question versionable id to old id
        question.template.questions.each do |q|
          old_question_ids[q.versionable_id] = q.id
        end
      end

      question = get_modifiable(question)

      question_id_map = {}
      if new_version
        # params now out of sync (after versioning) with the question_options
        # so when we do the question.update it'll mess up
        # need to remap params to keep them consistent
        old_to_new_opts = {}
        question.question_options.each do |opt|
          old_id = old_number_to_id[opt.number]
          old_to_new_opts[old_id.to_s] = opt.id.to_s
        end

        question.template.questions.each do |q|
          question_id_map[old_question_ids[q.versionable_id].to_s] = q.id.to_s
        end
      end

      # rewrite the question_option ids so they match the new
      # version of the question
      # and also rewrite the remove_data question ids
      attrs = question_params
      attrs = update_option_ids(attrs, old_to_new_opts) if new_version

      # Need to reattach the incoming annotation's and question_options to the
      # modifiable (versioned) question
      attrs = transfer_associations(attrs, question) if new_version

      # If the user unchecked all of the themes set the association to an empty array
      # add check for number present to ensure this is not just an annotation
      attrs[:theme_ids] = [] if attrs[:theme_ids].blank? && attrs[:number].present?
      if question.update(attrs)
        if question.update_conditions(sanitize_hash(params["conditions"]),
                                      old_to_new_opts, question_id_map)
          flash[:notice] = success_message(question, _("updated"))
        end
      else
        flash[:alert] = flash[:alert] = failure_message(question, _("update"))
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
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:enable

    # DELETE /org_admin/templates/:template_id/phases/:phase_id/sections/:section_id/questions/:id
    # rubocop:disable Metrics/AbcSize
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
      rescue StandardError
        flash[:alert] = _("Unable to create a new version of this template.")
      end
      redirect_to edit_org_admin_template_phase_path(
        template_id: section.phase.template.id,
        id: section.phase.id,
        section: section.id
      )
    end
    # rubocop:enable Metrics/AbcSize

    private

    # param_conditions looks like:
    #   [
    #     {
    #       "conditions_N" => {
    #         name: ...
    #         subject ...
    #         ...
    #       }
    #       ...
    #     }
    #   ]
    def sanitize_hash(param_conditions)
      return {} if param_conditions.nil?
      return {} if param_conditions.empty?

      res = {}
      hash_of_hashes = param_conditions[0]
      hash_of_hashes.each do |cond_name, cond_hash|
        sanitized_hash = {}
        cond_hash.each do |k, v|
          v = ActionController::Base.helpers.sanitize(v) if k.start_with?("webhook")
          sanitized_hash[k] = v
        end
        res[cond_name] = sanitized_hash
      end
      res
    end

    # TODO: Technically the :conditions, :option_comment_display, :default_value,
    #       :annotations_attributes and :theme_ids should all be passed within
    #       the context of :question. The forms are fragile right now though so
    #       recommend holding off until we rework this page in the future.
    def question_params
      params.require(:question)
            .permit(:number, :text, :question_format_id, :option_comment_display,
                    :default_value,
                    question_options_attributes: %i[id number text is_default _destroy],
                    annotations_attributes: %i[id text org_id org type _destroy],
                    theme_ids: [])
    end

    # when a template gets versioned while saving the question
    # options are now out of sync with the params.
    # This sorts that out.
    def update_option_ids(attrs_in, opt_map)
      qopts = attrs_in["question_options_attributes"]
      qopts.each_pair do |_, attr_hash|
        old_id = attr_hash["id"]
        new_id = opt_map[old_id]
        attr_hash["id"] = new_id
      end
      attrs_in
    end

    # When a template gets versioned by changes to one of its questions we need to loop
    # through the incoming params and ensure that the annotations and question_options
    # get attached to the new question
    def transfer_associations(attrs, question)
      if attrs[:annotations_attributes].present?
        attrs[:annotations_attributes].each_pair do |_, value|
          old_annotation = question.annotations.select do |a|
            a.org_id.to_s == value[:org_id] &&
              a.type.to_s == value[:type]
          end
          value[:id] = old_annotation.first.id unless old_annotation.empty?
        end
      end
      attrs
    end

  end

end
