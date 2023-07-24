# frozen_string_literal: true

module Dmptool
  # Custom home page logic
  module PlansController
    # POST /plans/:id/set_featured
    def set_featured
      plan = ::Plan.find(params[:id])
      authorize plan
      plan.featured = params[:featured] == '1'

      # Don't change the updated_at timestamp here
      if plan.save(touch: false)
        msg = _('Project \'%{title}\' is no longer featured.')
        msg = _('Project \'%{title}\' is now featured.') if plan.featured?
        render json: { code: 1, msg: format(msg, title: plan.title) }
      else
        render status: :bad_request, json: {
          code: 0, msg: _("Unable to change the plan's featured status")
        }
      end
    end

    # GET /plans/:id/follow_up
    def follow_up
      @plan = ::Plan.find(params[:id])
      authorize @plan
    end

    # PATCH /plans/:id/follow_up_update
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def follow_up_update
      @plan = ::Plan.find(params[:id])
      authorize @plan

      attrs = plan_params

      # Save the related_identifiers first. For some reason Rails is auto deleting them and then re-adding
      # if you just pass in the params as is :/
      #
      # So delete removed ones, add new ones, and leave the others alone
      ids = attrs[:related_identifiers_attributes].to_h.values.compact.map { |item| item['id'] }
      @plan.related_identifiers.reject { |identifier| ids.include?(identifier.id.to_s) }.each(&:destroy)

      attrs[:related_identifiers_attributes].each do |_idx, related_identifier|
        next if related_identifier[:id].present? || related_identifier[:value].blank?

        RelatedIdentifier.create(related_identifier.merge({ identifiable: @plan }))
      end
      attrs.delete(:related_identifiers_attributes)

      @plan.grant = plan_params[:grant]
      attrs.delete(:grant)

      @plan.title = @plan.title.strip

      if @plan.update(attrs)
        redirect_to follow_up_plan_path, notice: success_message(@plan, _('saved'))
      else
        redirect_to follow_up_plan_path, alert: failure_message(@plan, _('save'))
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    def create_from_funder_requirements
      plan = ::Plan.new
      authorize plan

      # If the template_id is blank then we need to look up the available templates and
      # return JSON
      if plan_params[:template_id].blank?
        # Something went wrong there should always be a template id
        respond_to do |format|
          flash[:alert] = _('Unable to identify a suitable template for your plan.')
          format.html { redirect_to new_plan_path }
        end
      else
        @plan = create_plan(plan: plan, params: plan_params)

        if @plan.is_a?(Plan)
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
            msg += " #{_('This plan is based on the')} #{@plan.template.org.name}: '#{@plan.template.title}' template."
          end

          respond_to do |format|
            flash[:notice] = msg
            format.html { redirect_to plan_path(@plan) }
          end
        else
          # Something went wrong so report the issue to the user
          respond_to do |format|
            flash[:alert] = failure_message(plan, _('create'))
            format.html { redirect_to new_plan_path }
          end
        end
      end
    end

    def temporary_patch_delete_me_later
      # This is a temporary patch to fix an issue with one of the pt-BR translations
      # in the DMPRoadmap translation.io
      #
      # It overrides the application_controller.rb :success_message function
      format(_('Successfully %{action} the %{object}.'), object: obj_name_for_display(obj), action: action || 'save')
    end

    private

    def create_plan(plan:, params:)
      plan.visibility = if params['visibility'].blank?
                          Rails.configuration.x.plans.default_visibility
                        else
                          plan_params[:visibility]
                        end

      plan.template = ::Template.find(params[:template_id])

      plan.title = if params[:title].blank?
                      if current_user.firstname.blank?
                        format(_('My Plan (%{title})'), title: plan.template.title)
                      else
                        format(_('%{user_name} Plan'), user_name: "#{current_user.firstname}'s")
                      end
                    else
                      params[:title]
                    end

      plan.org = process_org!(user: current_user)
      # If the user said there was no research org, use their org since Plan requires one
      plan.org = current_user.org if plan.org.blank?
      plan.funder = process_org!(user: current_user, namespace: 'funder')

      plan.title = plan.title.strip

      if plan.save
        # pre-select org's guidance and the default org's guidance
        ids = (::Org.default_orgs.pluck(:id) << plan.org_id).flatten.uniq
        ggs = ::GuidanceGroup.where(org_id: ids, optional_subset: false, published: true)

        plan.guidance_groups << ggs unless ggs.empty?
        plan.add_user!(current_user.id, :creator)

        # Set new identifier to plan id by default on create.
        # (This may be changed by user.)
        # ================================================
        # Start DMPTool customization
        #    We are using this field as a Funding Opportunity Number
        # ================================================
        # @plan.identifier = @plan.id.to_s
        # ================================================
        # End DMPTool customization
        # ================================================
        plan.save
        plan
      else
        nil
      end
    end
  end
end
