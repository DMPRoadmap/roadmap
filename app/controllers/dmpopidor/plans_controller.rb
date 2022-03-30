# frozen_string_literal: true

module Dmpopidor
  # Customized code for PlansController
  # rubocop:disable Metrics/ModuleLength
  module PlansController
    include MadmpImportHelper
    # CHANGES:
    # Added Active Flag on Org
    # rubocop:disable Metrics/AbcSize
    def new
      @plan = ::Plan.new
      authorize @plan

      # Get all of the available funders and non-funder orgs
      @funders = ::Org.funder
                      .includes(identifiers: :identifier_scheme)
                      .joins(:templates)
                      .where(templates: { published: true }).uniq.sort_by(&:name)
      @orgs = (::Org.includes(identifiers: :identifier_scheme).managed.organisation +
               ::Org.includes(identifiers: :identifier_scheme).managed.institution +
               ::Org.includes(identifiers: :identifier_scheme).managed.default_orgs)
      @orgs = @orgs.flatten
                   .select { |org| org.active == true }
                   .uniq.sort_by(&:name)

      @plan.org_id = current_user.org&.id

      # Get the default template
      @default_template = ::Template.default

      # TODO: is this still used? We cannot switch this to use the :plan_params
      #       strong params because any calls that do not include `plan` in the
      #       query string will fail
      flash[:notice] = "#{_('This is a')} <strong>#{_('test plan')}</strong>" if params.key?(:test)
      @is_test = params[:test] ||= false
      respond_to :html
    end
    # rubocop:enable Metrics/AbcSize

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

    def budget
      @plan = ::Plan.find(params[:id])
      dmp_fragment = @plan.json_fragment
      @costs = Fragment::Cost.where(dmp_id: dmp_fragment.id)
      authorize @plan
      render(:budget, locals: { plan: @plan, costs: @costs })
    end

    def import
      @plan = ::Plan.new
      authorize @plan

      @templates = ::Template.includes(:org)
                             .where(type: 'structured')
                             .unarchived.published
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def import_plan
      @plan = ::Plan.new
      authorize @plan

      if import_params[:template_id].blank?
        # Something went wrong there should always be a template id
        respond_to do |format|
          flash[:alert] = _('Unable to identify a suitable template for your plan.')
          format.html { redirect_to new_plan_path }
        end
      else
        json_file = import_params[:json_file]

        @plan.visibility = Rails.configuration.x.plans.default_visibility

        @plan.template = ::Template.find(import_params[:template_id])

        @plan.title = format(_('%<user_name>s Plan'), user_name: "#{current_user.firstname}'s")
        @plan.org = current_user.org
        if @plan.save
          @plan.add_user!(current_user.id, :creator)
          @plan.save
          @plan.create_plan_fragments

          import_dmp(@plan, json_file, import_params[:format])

          respond_to do |format|
            flash[:notice] = success_message(@plan, _('imported'))
            format.html { redirect_to plan_path(@plan) }
          end
        else
          # Something went wrong so report the issue to the user
          respond_to do |format|
            flash[:alert] = failure_message(@plan, _('create'))
            format.html { redirect_to new_plan_path }
          end
        end
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    private

    def import_params
      params.require(:import)
            .permit(:format, :template_id, :json_file)
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
  end
  # rubocop:enable Metrics/ModuleLength
end
