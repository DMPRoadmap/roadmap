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
        render json: { code: 1, msg: msg % { title: plan.title } }
      else
        render status: :bad_request, json: {
          code: 0, msg: _("Unable to change the plan's featured status")
        }
      end
    end
  end
end
