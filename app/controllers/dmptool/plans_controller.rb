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
        msg = _('Project \'%<title>s\' is no longer featured.')
        msg = _('Project \'%<title>s\' is now featured.') if plan.featured?
        render json: { code: 1, msg: format(msg, title: plan.title) }
      else
        render status: :bad_request, json: {
          code: 0, msg: _("Unable to change the plan's featured status")
        }
      end
    end

    def temporary_patch_delete_me_later
      # This is a temporary patch to fix an issue with one of the pt-BR translations
      # in the DMPRoadmap translation.io
      #
      # It overrides the application_controller.rb :success_message function
      format(_('Successfully %<action>s the %<object>s.'), object: obj_name_for_display(obj), action: action || 'save')
    end
  end
end
