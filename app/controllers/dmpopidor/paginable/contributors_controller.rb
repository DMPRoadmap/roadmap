# frozen_string_literal: true

module Dmpopidor
  module Paginable
    # Customized code for Paginable ContributorsController
    module ContributorsController
      # GET /paginable/plans/:plan_id/contributors
      # GET /paginable/plans/:plan_id/contributors/index/:page
      def index
        @plan = ::Plan.find_by(id: params[:plan_id])
        dmp_fragment = @plan.json_fragment
        authorize @plan, :show?
        paginable_renderise(
          partial: 'index',
          scope: dmp_fragment.persons.order(
            Arel.sql("data->>'lastName', data->>'firstName'")
          ),
          format: :json
        )
      end
    end
  end
end
