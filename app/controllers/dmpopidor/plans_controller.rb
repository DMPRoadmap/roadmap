# frozen_string_literal: true

module Dmpopidor
  # Customized code for PlansController
  # rubocop:disable Metrics/ModuleLength
  module PlansController
    include Dmpopidor::ErrorHelper

    # CHANGES:
    # - Emptied method as logic is now handled by ReactJS
    def new
      authorize ::Plan.new
      respond_to :html
    end

    # POST /plans
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def create
      @plan = ::Plan.new
      authorize @plan
      # If the template_id is blank then we need to look up the available templates and
      # return JSON
      if plan_params[:template_id].blank?
        render json: {
          message: _('Unable to identify a suitable template for your plan.')
        }, status: 400
      else
        @plan.visibility = Rails.configuration.x.plans.default_visibility

        @plan.template = ::Template.find(plan_params[:template_id])

        @plan.title = if current_user.firstname.blank?
                        format(_('My Plan (%{title})'), title: @plan.template.title)
                      else
                        format(_('%{user_name} Plan'), user_name: "#{current_user.firstname}'s")
                      end
        if @plan.save
          # pre-select org's guidance and the default org's guidance
          ids = (::Org.default_orgs.pluck(:id) << @plan.org_id).flatten.uniq
          ggs = ::GuidanceGroup.where(org_id: ids, optional_subset: false, published: true)

          @plan.guidance_groups << ggs unless ggs.empty?

          default = ::Template.default

          msg = "#{success_message(@plan, _('created'))}<br />"

          if !default.nil? && default == @plan.template
            # We used the generic/default template
            msg += " #{_('This plan is based on the default template.')}"

          elsif !@plan.template.customization_of.nil?
            # We used a customized version of the the funder template
            # rubocop:disable Layout/LineLength
            msg += " #{_('This plan is based on the')} #{@plan.funder&.name}: '#{@plan.template.title}' #{_('template with customisations by the')} #{@plan.template.org.name}"
            # rubocop:enable Layout/LineLength
          else
            # We used the specified org's or funder's template
            msg += format(_('This plan is based on the "%{template_title}" template provided by %{org_name}.'),
                          template_title: @plan.template.title, org_name: @plan.template.org.name)
          end

          @plan.add_user!(current_user.id, :creator)
          @plan.save
          # Initialize Meta & Project
          @plan.create_plan_fragments

          # Add default research output if possible
          created_ro = @plan.research_outputs.create!(
            abbreviation: 'Default',
            title: 'Default research output',
            is_default: true,
            display_order: 1
          )
          created_ro.create_json_fragments

          flash[:notice] = msg
          render json: {
            id: @plan.id
          }, status: 200

        else
          # Something went wrong so report the issue to the user
          render json: {
            message: failure_message(@plan, _('create'))
          }, status: 400
        end
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # CHANGES:
    # - Kept only necessary code as logic is now handled by ReactJS
    def show
      @plan = ::Plan.includes(
        template: [:phases]
      ).find(params[:id])
      authorize @plan

      @visibility = if @plan.visibility.present?
                      @plan.visibility.to_s
                    else
                      Rails.configuration.x.plans.default_visibility
                    end

      respond_to :html
    end

    # PUT /plans/1
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def update
      @plan = ::Plan.find(params[:id])
      authorize @plan
      # rubocop:disable Metrics/BlockLength
      respond_to do |format|
        # TODO: See notes below on the pan_params definition. We should refactor
        #       this once the UI pages have been reworked
        # Save the guidance group selections
        guidance_group_ids = if params[:guidance_group_ids].blank?
                               []
                             else
                               params[:guidance_group_ids].map(&:to_i).uniq
                             end
        @plan.guidance_groups = ::GuidanceGroup.where(id: guidance_group_ids)

        if @plan.save # _attributes(attrs)
          format.html do
            redirect_to plan_path(@plan),
                        notice: success_message(@plan, _('saved'))
          end
          format.json do
            render json: { code: 1, msg: success_message(@plan, _('saved')) }
          end
        else
          format.html do
            # TODO: Should do a `render :show` here instead but show defines too many
            #       instance variables in the controller
            redirect_to plan_path(@plan).to_s, alert: failure_message(@plan, _('save'))
          end
          format.json do
            render json: { code: 0, msg: failure_message(@plan, _('save')) }
          end
        end
      rescue StandardError => e
        flash[:alert] = failure_message(@plan, _('save'))
        format.html do
          Rails.logger.error "Unable to save plan #{@plan&.id} - #{e.message}"
          redirect_to plan_path(@plan).to_s, alert: failure_message(@plan, _('save'))
        end
        format.json do
          render json: { code: 0, msg: flash[:alert] }
        end
      end
      # rubocop:enable Metrics/BlockLength
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def edit
      plan = ::Plan.includes(
        { template: :phases }
      )
                   .find(params[:id])
      authorize plan
      template = plan.template
      render('/phases/edit', locals:
        {
          plan:,
          template:,
          locale: template.locale
        })
    end

    # GET /plans/:id/guidance_groups
    def budget
      @plan = ::Plan.find(params[:id])
      dmp_fragment = @plan.json_fragment
      @costs = Fragment::Cost.where(dmp_id: dmp_fragment.id)
      authorize @plan
      render(:budget, locals: { plan: @plan, costs: @costs })
    end

    def guidance_groups
      @all_ggs_grouped_by_org = get_guidances_groups(params[:id])
      render json: {
        status: 200,
        message: 'Guidance groups',
        guidance_groups: @all_ggs_grouped_by_org,
      },status: :ok
    end

    def select_guidance_groups
      begin
        @plan = ::Plan.find(params[:id])
        authorize @plan

        body = JSON.parse(request.raw_post)

        selected_ids = body["guidance_group_ids"]

        guidance_group_ids = if selected_ids.blank?
                                []
                              else
                                selected_ids.map(&:to_i).uniq
                              end

        @plan.guidance_groups = ::GuidanceGroup.where(id: guidance_group_ids)

        guidance_presenter = ::GuidancePresenter.new(@plan)

        if @plan.save
          @all_ggs_grouped_by_org = get_guidances_groups(params[:id])
          render json: {
              status: 200,
              message: "Guidances updated for plan [#{params[:id]}]",
              guidance_groups: @all_ggs_grouped_by_org,
              questions_with_guidance: @plan.template.questions.select do |q|
                question = ::Question.find(q.id)
                guidance_presenter.any?(question:)
              end.pluck(:id)
          }, status: :ok
        else
          Rails.logger.error("Plan [#{params[:id]}] not updated")
          internal_server_error("Plan [#{params[:id]}] not updated")
        end
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error("Plan [#{params[:id]}] not found")
        not_found("Plan [#{params[:id]}] not found")
      rescue JSON::ParserError, TypeError => e
        Rails.logger.error("Bad request - Invalid JSON data")
        bad_request("Bad request - Invalid JSON data")
      rescue StandardError => e
        Rails.logger.error("Internal server error - #{e.message}")
        internal_server_error("Internal server error - #{e.message}")
      end
    end

    def question_guidances
      plan_id = params[:id]
      unless plan_id && plan_id.to_i.positive?
        bad_request("Plan [#{plan_id}] id, must be present or positive value")
        return
      end

      question_id = params[:question]
      unless question_id && question_id.to_i.positive?
        bad_request("Question [#{question_id}] id, must be present or positive value")
        return
      end

      begin
        @plan = ::Plan.find(plan_id)
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error("Plan [#{plan_id}] not found")
        Rails.logger.error(e.backtrace.join("\n"))
        not_found('No plan found')
        return
      rescue StandardError => e
        Rails.logger.error('An error occured during retriving plan data')
        Rails.logger.error(e.backtrace.join("\n"))
        internal_server_error(e.message)
        return
      end

      begin
        authorize @plan
      rescue Pundit::NotAuthorizedError => e
        Rails.logger.error('An error occurred while checking authorisations')
        Rails.logger.error(e.backtrace.join("\n"))
        forbidden
        return
      end

      begin
        question = ::Question.find(question_id)
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error("Question [#{plan_id}] not found")
        Rails.logger.error(e.backtrace.join("\n"))
        not_found('No plan found')
        return
      rescue StandardError => e
        Rails.logger.error('An error occured during retriving question data')
        Rails.logger.error(e.backtrace.join("\n"))
        internal_server_error(e.message)
        return
      end

      begin
        guidance_presenter = ::GuidancePresenter.new(@plan)
        guidances = guidance_presenter.tablist(question)
      rescue StandardError => e
        Rails.logger.error("Cannot create guidance presenter")
        Rails.logger.error(e.backtrace.join("\n"))
        internal_server_error('An error occured during guidance presenter creation')
        return
      end

      render json: { status: 200, message: "Guidances for plan [#{plan_id}] and question [#{question_id}]", guidances: guidances }, status: :ok
    end

    def import
      @plan = ::Plan.new
      authorize @plan

      @templates = ::Template.includes(:org)
                             .where(type: 'structured', customization_of: nil)
                             .unarchived.published
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    # rubocop:disable Metrics/PerceivedComplexity
    def import_plan
      @plan = ::Plan.new
      authorize @plan
      # rubocop:disable Metrics/BlockLength
      ::Plan.transaction do
        respond_to do |format|
          json_file = import_params[:json_file]
          if json_file.respond_to?(:read)
            json_data = JSON.parse(json_file.read)
          elsif json_file.respond_to?(:path)
            json_data = JSON.parse(File.read(json_file.path))
          else
            raise IOError
          end
          errs = Import::PlanImportService.validate(json_data, import_params[:format])
          if errs.any?
            format.html { redirect_to import_plans_path, alert: import_errors(errs) }
          else
            @plan.visibility = Rails.configuration.x.plans.default_visibility

            @plan.template = ::Template.find(import_params[:template_id])

            @plan.title = format(_('%{user_name} Plan'), user_name: "#{current_user.firstname}'s")
            @plan.org = current_user.org

            if @plan.save
              @plan.add_user!(current_user.id, :creator)
              @plan.save
              @plan.create_plan_fragments

              Import::PlanImportService.import(@plan, json_data, import_params[:format])

              format.html { redirect_to plan_path(@plan), notice: success_message(@plan, _('imported')) }
            else
              format.html { redirect_to import_plans_path, alert: failure_message(@plan, _('create')) }
            end
          end
        rescue IOError
          format.html { redirect_to import_plans_path, alert: _('Unvalid file') }
        rescue JSON::ParserError
          msg = _('File should contain JSON')
          format.html { redirect_to import_plans_path, alert: msg }
        rescue StandardError => e
          msg = "#{_('An error has occured: ')} #{e.message}"
          Rails.logger.error e.backtrace
          format.html { redirect_to import_plans_path, alert: msg }
        end
      end
      # rubocop:enable Metrics/BlockLength
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def answers_data
      plan = ::Plan.includes(
        :research_outputs,
        { answers: %i[notes madmp_fragment] }
      ).find(params[:id])
      authorize plan

      guidance_presenter = ::GuidancePresenter.new(plan)
      render json: {
        id: plan.id,
        dmp_id: plan.json_fragment.id,
        research_outputs: plan.research_outputs.order(:display_order).map do |ro|
          {
            id: ro.id,
            abbreviation: ro.abbreviation,
            title: ro.title,
            order: ro.display_order,
            hasPersonalData: ro.has_personal_data,
            answers: ro.answers.map do |a|
              {
                answer_id: a.id,
                question_id: a.question_id,
                fragment_id: a.madmp_fragment.id
              }
            end
          }
        end,
        questions_with_guidance: plan.template.questions.select do |q|
          question = ::Question.find(q.id)
          guidance_presenter.any?(question:)
        end.pluck(:id)
      }
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    private

    def import_params
      params.require(:import)
            .permit(:format, :template_id, :json_file)
    end

    def import_errors(errs)
      msg = "#{_('Invalid JSON: ')} <ul>"
      errs.each do |err|
        msg += "<li>#{err}</li>"
      end
      msg += '</ul>'
      msg
    end

    # Get the parameters corresponding to the schema
    def schema_params(schema, form_prefix, flat: false)
      s_params = schema.generate_strong_params(flat: flat)
      params.require(:plan)[form_prefix].permit(s_params)
    end

    # CHANGES : maDMP Fragments SUPPORT
    def render_phases_edit(plan, phase, guidance_groups)
      readonly = !plan.editable_by?(current_user.id)
      @schemas = ::MadmpSchema.all
      # Since the answers have been pre-fetched through plan (see Plan.load_for_phase)
      # we create a hash whose keys are question id and value is the answer associated
      answers = plan.answers
                    .includes(:madmp_fragment)
                    .each_with_object({}) { |a, m| m["#{a.question_id}_#{a.research_output_id}"] = a }
      render('/phases/edit', locals: {
               base_template_org: phase.template.base_org,
               plan: plan,
               phase: phase,
               readonly: readonly,
               guidance_groups: guidance_groups,
               answers: answers,
               guidance_presenter: GuidancePresenter.new(plan)
             })
    end

    def get_guidances_groups(id)
      @plan = ::Plan.includes(
        :guidance_groups, template: [:phases]
      ).find(id)
      authorize @plan

      @visibility = if @plan.visibility.present?
                      @plan.visibility.to_s
                    else
                      Rails.configuration.x.plans.default_visibility
                    end

      @all_guidance_groups = @plan.guidance_group_options
      @all_ggs_grouped_by_org = @all_guidance_groups.sort.group_by(&:org)
      @selected_guidance_groups = @plan.guidance_groups.ids.to_set

      @default_orgs = ::Org.default_orgs

      @all_ggs_grouped_by_org.map do |key, value|
        {
          name: key.name,
          id: key.id,
          important: @default_orgs.include?(key) || value.any? { |item| @selected_guidance_groups.include?(item.id) },
          guidances: value.map do |item|
            {
              id: item.id,
              name: item.name,
              selected: @selected_guidance_groups.include?(item.id)
            }
          end
        }
      end
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
