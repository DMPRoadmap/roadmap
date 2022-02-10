# frozen_string_literal: true

module Dmpopidor

  module Paginable

    module ContributorsController

      # GET /paginable/plans/:plan_id/contributors
      # GET /paginable/plans/:plan_id/contributors/index/:page
      def index
        @plan = Plan.find_by(id: params[:plan_id])
        dmp_fragment = @plan.json_fragment
        authorize @plan
        paginable_renderise(
          partial: "index",
          scope: dmp_fragment.persons,
          format: :json
        )
      end

    end

  end

end
