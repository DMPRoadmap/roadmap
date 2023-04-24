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

    def temporary_patch_delete_me_later
      # This is a temporary patch to fix an issue with one of the pt-BR translations
      # in the DMPRoadmap translation.io
      #
      # It overrides the application_controller.rb :success_message function
      format(_('Successfully %{action} the %{object}.'), object: obj_name_for_display(obj), action: action || 'save')
    end
  end
end
