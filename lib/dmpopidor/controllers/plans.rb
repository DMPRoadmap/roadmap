module Dmpopidor
    module Controller
      module Plans

        # POST /plans
        def create
          @plan = Plan.new
          authorize @plan

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

        # Added 'All' if the user wants to export all phases
        def download
          @plan = Plan.find(params[:id])
          authorize @plan
          @phase_options = @plan.phases.order(:number).pluck(:title, :id)
          @phase_options.unshift([_('All'), nil])
          @export_settings = @plan.settings(:export)
          render "download"
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
      end
    end
  end