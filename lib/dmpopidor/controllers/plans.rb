# frozen_string_literal: true

module Dmpopidor

  module Controllers

    module Plans

      # CHANGES:
      # Added Active Flag on Org
      def new
        @plan = Plan.new
        authorize @plan

        # Get all of the available funders and non-funder orgs
        @funders = Org.funder
                      .includes(identifiers: :identifier_scheme)
                      .joins(:templates)
                      .where(templates: { published: true }).uniq.sort_by(&:name)

        @orgs = (Org.includes(identifiers: :identifier_scheme).managed.organisation +
                 Org.includes(identifiers: :identifier_scheme).managed.institution +
                 Org.includes(identifiers: :identifier_scheme).managed.default_orgs)
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

      # CHANGES:
      # Added Research Output Support
      def create
        @plan = Plan.new
        authorize @plan
        # We set these ids to -1 on the page to trick ariatiseForm into allowing the
        # autocomplete to be blank if the no org/funder checkboxes are checked off
        org_id = (plan_params[:org_id] == "-1" ? "" : plan_params[:org_id])

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

          if plan_params[:title].blank?
            @plan.title = if current_user.firstname.blank?
                            _("My Plan") + "(" + @plan.template.title + ")"
                          else
                            current_user.firstname + "'s" + _(" Plan")
                          end
          else
            @plan.title = plan_params[:title]
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
            ids = (Org.default_orgs.pluck(:id) << current_user.org_id << org_id).flatten.uniq
            ggs = GuidanceGroup.where(org_id: ids, optional_subset: false, published: true)

            if !ggs.blank? then @plan.guidance_groups << ggs end

            default = Template.default

            msg = "#{success_message(@plan, _('created'))}<br />"

            if !default.nil? && default == @plan.template
              # We used the generic/default template
              msg += " #{_('This plan is based on the default template.')}"

            elsif !@plan.template.customization_of.nil?
              # We used a customized version of the the funder template
              # rubocop:disable Metrics/LineLength
              msg += " #{d_('dmpopidor', 'This plan is based on the %{funder_name}: %{template_name} template with customisations by the %{org_name}') % { 
                  funder_name: @plan.funder&.name,
                  template_name: @plan.template.title,
                  org_name: plan_params[:org_name]
              } }"
              # rubocop:enable Metrics/LineLength
            else
              # We used the specified org's or funder's template
              # rubocop:disable Metrics/LineLength
              msg += " #{d_('dmpopidor', 'This plan is based on the %{org_name}: %{template_name} template') % { org_name: @plan.template.org.name, template_name: @plan.template.title} }"
              # rubocop:enable Metrics/LineLength
            end

            @plan.add_user!(current_user.id, :creator)

            @plan.create_plan_fragments

            # Add default research output if possible
            @plan.research_outputs.create(
              abbreviation: "Default",
              fullname: "Default research output",
              is_default: true,
              type: ResearchOutputType.find_by(label: "Dataset"),
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

      # GET /plans/show
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
          if org.organisation?
            @important_ggs << [org, ggs]
          end

          # If this is one of the already selected guidance groups its important!
          if !(ggs & @selected_guidance_groups).empty?
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

      # GET /plans/:plan_id/phases/:id/edit
      # CHANGES :
      # Added Research Output Support
      def edit
        plan = Plan.includes(:research_outputs).find(params[:id])
        authorize plan
        plan, phase = Plan.load_for_phase(params[:id], params[:phase_id])
        guidance_groups = GuidanceGroup.where(published: true, id: plan.guidance_group_ids)
        render_phases_edit(plan, phase, guidance_groups)
      end

      # PUT /plans/1
      # PUT /plans/1.json
      # CHANGES :
      # Added Research Output Support
      # Added DMP, Meta & Project update
      def update
        @plan = Plan.find(params[:id])
        authorize @plan
        attrs = plan_params
        # rubocop:disable Metrics/BlockLength
        respond_to do |format|
          begin
            # Save the guidance group selections
            guidance_group_ids = if params[:guidance_group_ids].blank?
                                   []
                                 else
                                   params[:guidance_group_ids].map(&:to_i).uniq
                                 end
            @plan.guidance_groups = GuidanceGroup.where(id: guidance_group_ids)
            # TODO: For some reason the `fields_for` isn't adding the
            #       appropriate namespace, so org_id represents our funder
            funder = org_from_params(params_in: attrs, allow_create: true)
            @plan.funder_id = funder.id if funder.present?
            process_grant(hash: params[:grant])
            attrs = remove_org_selection_params(params_in: attrs)

            if @plan.update(attrs) #_attributes(attrs)
              format.html do
                redirect_to plan_contributors_path(@plan),
                            notice: success_message(@plan, _("saved"))
              end
              format.json do
                render json: { code: 1, msg: success_message(@plan, _("saved")) }
              end
            else
              format.html do
                # TODO: Should do a `render :show` here instead but show defines too many
                #       instance variables in the controller
                redirect_to "#{plan_path(@plan)}", alert: failure_message(@plan, _("save"))
              end
              format.json do
                p "################"
                p @plan.errors
                p "################"
                render json: { code: 0, msg: failure_message(@plan, _("save")) }
              end
            end
          rescue Exception => e
            p "################"
            p e.message
            p e.backtrace[0]
            p "################"
            flash[:alert] = failure_message(@plan, _("save"))
            format.html do
              Rails.logger.error "Unable to save plan #{@plan&.id} - #{e.message}"
              redirect_to "#{plan_path(@plan)}", alert: failure_message(@plan, _("save"))
            end
            format.json do
              render json: { code: 0, msg: flash[:alert] }
            end
          end
        end
        # rubocop:enable Metrics/BlockLength
      end

      # POST /plans/:id/visibility
      def visibility
        plan = Plan.find(params[:id])
        if plan.present?
          authorize plan
          if plan.visibility_allowed?
            plan.visibility = plan_params[:visibility]
            if plan.save
              deliver_if(recipients: plan.owner_and_coowners,
                        key: "owners_and_coowners.visibility_changed") do |r|
                UserMailer.plan_visibility(r, plan).deliver_now()
              end
              redirect_to :back, notice: success_message(plan, _("updated"))
            else
              redirect_to :back, notice: failure_message(plan, _("update"))
            end
          else
            # rubocop:disable Metrics/LineLength
            redirect_to :back, notice: failure_message(
              _("Unable to change the plan's status since it is needed at least %{percentage} percentage responded") % {
                percentage: Rails.application.config.default_plan_percentage_answered
              }
            )
            # rubocop:enable Metrics/LineLength
          end
        else
          redirect_to :back, notice: failure_message(
            _("Unable to find plan id %{plan_id}") % { plan_id: params[:id] }
          )
        end
      end

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
                      org: [:org_id, :org_name, :org_sources, :org_crosswalk],
                      funder: [:org_id, :org_name, :org_sources, :org_crosswalk])
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
                      .reduce({}) { |m, a| m["#{a.question_id}_#{a.research_output_id}"] = a; m }
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

  end

end
