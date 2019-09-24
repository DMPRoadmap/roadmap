module Dmpopidor
    module Controllers
      module Plans

        # CHANGES:
        # Added plan creation from link
        def index
          authorize Plan
          @plans = Plan.active(current_user).page(1)
          if current_user.org.is_other?
            @organisationally_or_publicly_visible = []
          else
            @organisationally_or_publicly_visible =
              Plan.organisationally_or_publicly_visible(current_user).page(1)
          end

          if params[:plan].present?
            @template = Template.find(params[:plan][:template_id])
          end
          
        end

        # CHANGES:
        # Added Privately private visibility
        # Added Research Output Support
        def create
          @plan = Plan.new
          authorize @plan

          # Add default research output if possible
          @plan.research_outputs.new(
            abbreviation: 'Default', 
            fullname: 'Default research output',
            is_default: true, 
            type: ResearchOutputType.find_by(label: "Dataset"),
            order: 1
          )

          # We set these ids to -1 on the page to trick ariatiseForm into allowing the
          # autocomplete to be blank if the no org/funder checkboxes are checked off
          org_id = (plan_params[:org_id] == "-1" ? "" : plan_params[:org_id])
          funder_id = (plan_params[:funder_id] == "-1" ? "" : plan_params[:funder_id])

          # If the template_id is blank then we need to look up the available templates and
          # return JSON
          if plan_params[:template_id].blank?
            # Something went wrong there should always be a template id
            respond_to do |format|
                flash[:alert] = _("Unable to identify a suitable template for your plan.")
                format.html { redirect_to new_plan_path }
            end
          else
          # Otherwise create the plan
            if current_user.surname.blank?
              @plan.principal_investigator = nil
            else
              @plan.principal_investigator = current_user.name(false)
            end

            @plan.principal_investigator_email = current_user.email

            orcid = current_user.identifier_for(IdentifierScheme.find_by(name: "orcid"))
            @plan.principal_investigator_identifier = orcid.identifier unless orcid.nil?

            @plan.funder_name = plan_params[:funder_name]

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

            if @plan.save
              # pre-select org's guidance and the default org's guidance
              ids = (Org.managing_orgs << org_id).flatten.uniq
              ggs = GuidanceGroup.where(org_id: ids, optional_subset: false, published: true)

              if !ggs.blank? then @plan.guidance_groups << ggs end

              default = Template.default

              msg = "#{success_message(@plan, _('created'))}<br />"

              if !default.nil? && default == @plan.template
                # We used the generic/default template
                msg += " #{_('This plan is based on the default template.')}"

              elsif !@plan.template.customization_of.nil?
                # rubocop:disable Metrics/LineLength
                # We used a customized version of the the funder template
                # rubocop:disable Metrics/LineLength
                msg += " #{d_('dmpopidor', 'This plan is based on the %{funder_name}: %{template_name} template with customisations by the %{org_name}') % { 
                    funder_name: plan_params[:funder_name], 
                    template_name: @plan.template.title,
                    org_name: plan_params[:org_name] 
                } }"# rubocop:enable Metrics/LineLength
              else
                # rubocop:disable Metrics/LineLength
                # We used the specified org's or funder's template
                # rubocop:disable Metrics/LineLength
                msg += " #{d_('dmpopidor', 'This plan is based on the %{org_name}: %{template_name} template') % { org_name: @plan.template.org.name, template_name: @plan.template.title} }"
                # rubocop:enable Metrics/LineLength
              end

              @plan.add_user!(current_user.id, :creator)

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
        

        # PUT /plans/1
        # PUT /plans/1.json
        # CHANGES :
        # Added Research Output Support
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
              @plan.save
              if @plan.update_attributes(attrs)
                @plan.research_outputs.toggle_default

                format.html do
                  redirect_to plan_research_outputs_path(@plan),
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
                  render json: { code: 0, msg: failure_message(@plan, _("save")) }
                end
              end

            rescue Exception
              flash[:alert] = failure_message(@plan, _("save"))
              format.html do
                render_phases_edit(@plan, @plan.phases.first, @plan.guidance_groups)
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

        # Removing test flag now put the plan in privately_private visibility
        def set_test
          plan = Plan.find(params[:id])
          authorize plan
          plan.visibility = (params[:is_test] === "1" ? :is_test : :privately_private_visible)
          # rubocop:disable Metrics/LineLength
          if plan.save
            render json: {
                     code: 1,
                     msg: (plan.is_test? ? _("Your project is now a test.") : _("Your project is no longer a test."))
                   }
          else
            render status: :bad_request, json: {
                     code: 0, msg: _("Unable to change the plan's test status")
                   }
          end
          # rubocop:enable Metrics/LineLength
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

      end
    end
  end