# frozen_string_literal: true

module Dmpopidor

  # rubocop:disable Metrics/ModuleLength
  module PlansController

    # CHANGES:
    # Added Active Flag on Org
    # rubocop:disable Metrics/AbcSize
    def new
      @plan = Plan.new
      authorize @plan

      # Get all of the available funders and non-funder orgs
      @funders = Org.funder
                    .includes(identifiers: :identifier_scheme)
                    .joins(:templates)
                    .where(templates: { published: true }).uniq.sort_by(&:name)

      @orgs = (Org.includes(identifiers: :identifier_scheme).organisation +
               Org.includes(identifiers: :identifier_scheme).institution +
               Org.includes(identifiers: :identifier_scheme).default_orgs)
      @orgs = @orgs.flatten
                   .select { |org| org.active == true }
                   .uniq.sort_by(&:name)

      @plan.org_id = current_user.org&.id

      # Get the default template
      @default_template = Template.default

      if params.key?(:test)
        flash[:notice] = "#{_('This is a')} <strong>#{_('test plan')}</strong>"
      end
      @is_test = params[:test] ||= false
      respond_to :html
    end
    # rubocop:enable Metrics/AbcSize

    # CHANGES:
    # Added Research Output Support
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def create
      @plan = Plan.new
      authorize @plan

      # If the template_id is blank then we need to look up the available templates and
      # return JSON
      if plan_params[:template_id].blank?
        # Something went wrong there should always be a template id
        respond_to do |format|
          flash[:alert] = _("Unable to identify a suitable template for your plan.")
          format.html { redirect_to new_plan_path }
        end
      else
        @plan.visibility = if plan_params["visibility"].blank?
                             Rails.application.config.default_plan_visibility
                           else
                             plan_params[:visibility]
                           end

        @plan.template = Template.find(plan_params[:template_id])

        @plan.title = if plan_params[:title].blank?
                        if current_user.firstname.blank?
                          _("My Plan") + "(" + @plan.template.title + ")"
                        else
                          current_user.firstname + "'s" + _(" Plan")
                        end
                      else
                        plan_params[:title]
                      end

        # bit of hackery here. There are 2 org selectors on the page
        # and each is within its own specific context, plan.org or
        # plan.funder which forces the hidden id hash to be :id
        # so we need to convert it to :org_id so it works with the
        # OrgSelectable and OrgSelection services
        org_hash = plan_params[:org] || params[:org]
        if org_hash[:id].present?
          org_hash[:org_id] = org_hash[:id]
          @plan.org = org_from_params(params_in: org_hash, allow_create: false)
        end
        funder_hash = plan_params[:funder] || params[:funder]
        if funder_hash[:id].present?
          funder_hash[:org_id] = funder_hash[:id]
          @plan.funder = org_from_params(params_in: funder_hash, allow_create: false)
        end

        if @plan.save
          # pre-select org's guidance and the default org's guidance
          ids = (Org.default_orgs.pluck(:id) << @plan.org_id).flatten.uniq
          ggs = GuidanceGroup.where(org_id: ids, optional_subset: false, published: true)

          @plan.guidance_groups << ggs unless ggs.empty?

          default = Template.default

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
            # rubocop:disable Metrics/LineLength
            msg += " #{_('This plan is based on the %{org_name}: %{template_name} template') % { org_name: @plan.template.org.name, template_name: @plan.template.title} }"
            # rubocop:enable Metrics/LineLength
          end

          @plan.add_user!(current_user.id, :creator)

          # Set new identifier to plan id by default on create.
          # (This may be changed by user.)
          @plan.identifier = @plan.id.to_s
          @plan.save

          @plan.create_plan_fragments

          # Add default research output if possible
          @plan.research_outputs.create(
            abbreviation: "Default",
            fullname: "Default research output",
            is_default: true,
            order: 1
          )

          respond_to do |format|
            flash[:notice] = msg
            format.html { redirect_to plan_path(@plan) }
          end

        else
          # Something went wrong so report the issue to the user
          respond_to do |format|
            flash[:alert] = failure_message(@plan, _("create"))
            format.html { redirect_to new_plan_path }
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # GET /plans/show
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def show
      @plan = Plan.includes(
        template: { phases: { sections: { questions: :answers } } },
        plans_guidance_groups: { guidance_group: :guidances }
      ).find(params[:id])
      @schemas = MadmpSchema.all
      authorize @plan

      @research_outputs = @plan.research_outputs.order(:order)

      @visibility = if @plan.visibility.present?
                      @plan.visibility.to_s
                    else
                      Rails.application.config.default_plan_visibility
                    end

      # TODO: Seems strange to do this. Why are we just not using an `edit` route?
      @editing = (!params[:editing].nil? && @plan.administerable_by?(current_user.id))

      # Get all Guidance Groups applicable for the plan and group them by org
      @all_guidance_groups = @plan.guidance_group_options
      @all_ggs_grouped_by_org = @all_guidance_groups.sort.group_by(&:org)
      @selected_guidance_groups = @plan.guidance_groups

      # Important ones come first on the page - we grab the user's org's GGs and
      # "Organisation" org type GGs
      @important_ggs = []

      if @all_ggs_grouped_by_org.include?(current_user.org)
        @important_ggs << [current_user.org, @all_ggs_grouped_by_org[current_user.org]]
      end
      @all_ggs_grouped_by_org.each do |org, ggs|
        @important_ggs << [org, ggs] if Org.default_orgs.include?(org)

        # If this is one of the already selected guidance groups its important!
        unless (ggs & @selected_guidance_groups).empty?
          @important_ggs << [org, ggs] unless @important_ggs.include?([org, ggs])
        end
      end

      # Sort the rest by org name for the accordion
      @important_ggs = @important_ggs.sort_by { |org, gg| (org.nil? ? "" : org.name) }
      @all_ggs_grouped_by_org = @all_ggs_grouped_by_org.sort_by do |org, gg|
        (org.nil? ? "" : org.name)
      end
      @selected_guidance_groups = @selected_guidance_groups.ids

      @based_on = if @plan.template.customization_of.nil?
                    @plan.template
                  else
                    Template.where(family_id: @plan.template.customization_of).first
                  end

      respond_to :html
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # GET /plans/:plan_id/phases/:id/edit
    # CHANGES :
    # Added Research Output Support
    def edit
      plan = Plan.includes(
        :research_outputs,
        { template: {
          phases: {
            sections: {
              questions: %i[question_format question_options annotations themes]
            }
          }
        } },
        { answers: :notes }
      )
                 .find(params[:id])

      authorize plan
      phase_id = params[:phase_id].to_i
      phase = plan.template.phases.select { |p| p.id == phase_id }.first
      raise ActiveRecord::RecordNotFound if phase.nil?

      guidance_groups = GuidanceGroup.where(published: true, id: plan.guidance_group_ids)
      render_phases_edit(plan, phase, guidance_groups)
    end

    # POST /plans/:id/visibility
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def visibility
      plan = Plan.find(params[:id])
      if plan.present?
        authorize plan
        if plan.visibility_allowed?
          plan.visibility = plan_params[:visibility]
          if plan.save
            deliver_if(recipients: plan.owner_and_coowners,
                       key: "owners_and_coowners.visibility_changed") do |r|
              UserMailer.plan_visibility(r, plan).deliver_now
            end
            render status: :ok,
                   json: { msg: success_message(plan, _("updated")) }
          else
            render status: :internal_server_error,
                   json: { msg: failure_message(plan, _("update")) }
          end
        else
          # rubocop:disable Layout/LineLength
          render status: :forbidden, json: {
            msg: _("Unable to change the plan's status since it is needed at least %{percentage} percentage responded") % {
              percentage: Rails.configuration.x.plans.default_percentage_answered
            }
          }
          # rubocop:enable Layout/LineLength
        end
      else
        render status: :not_found,
               json: { msg: _("Unable to find plan id %{plan_id}") % {
                 plan_id: params[:id]
               } }
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # CHANGES : Research Outputs support
    def download
      @plan = Plan.find(params[:id])
      authorize @plan
      @research_outputs = @plan.research_outputs
      @phase_options = @plan.phases.order(:number).pluck(:title, :id)
      @export_settings = @plan.settings(:export)
      render "download"
    end

    # CHANGES : MADMP_FRAGMENTS SUPPORT
    def destroy
      @plan = Plan.find(params[:id])
      dmp_fragment = @plan.json_fragment
      authorize @plan
      if @plan.destroy
        dmp_fragment.destroy
        respond_to do |format|
          format.html do
            redirect_to plans_url,
                        notice: success_message(@plan, _("deleted"))
          end
        end
      else
        respond_to do |format|
          flash[:alert] = failure_message(@plan, _("delete"))
          format.html { render action: "edit" }
        end
      end
    end

    def budget
      @plan = Plan.find(params[:id])
      dmp_fragment = @plan.json_fragment
      @costs = Fragment::Cost.where(dmp_id: dmp_fragment.id)
      authorize @plan
      render(:budget, locals: { plan: @plan, costs: @costs })
    end

    private

    # CHANGES : Removed everything except guidances group info. The rest of the info is 
    # handled by MadmpFragmentController
    def plan_params
      params.require(:plan)
            .permit(:org_id, :template_id, :funder_name, :visibility,
                    :title, :org_name, :guidance_group_ids,
                    research_outputs_attributes: %i[_destroy],
                    org: %i[id org_id org_name org_sources org_crosswalk],
                    funder: %i[id org_id org_name org_sources org_crosswalk])
    end

    # Get the parameters corresponding to the schema
    def schema_params(schema, form_prefix, flat = false)
      s_params = schema.generate_strong_params(flat)
      params.require(:plan)[form_prefix].permit(s_params)
    end

    # CHANGES : maDMP Fragments SUPPORT
    def render_phases_edit(plan, phase, guidance_groups)
      readonly = !plan.editable_by?(current_user.id)
      @schemas = MadmpSchema.all
      # Since the answers have been pre-fetched through plan (see Plan.load_for_phase)
      # we create a hash whose keys are question id and value is the answer associated
      answers = plan.answers
                    .includes(:madmp_fragment)
                    .each_with_object({}) { |m, a| m["#{a.question_id}_#{a.research_output_id}"] = a }
      render("/phases/edit", locals: {
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
