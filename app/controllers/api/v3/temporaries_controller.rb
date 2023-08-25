# frozen_string_literal: true

module Api
  module V3
    # Endpoints that act as the backend to Typeahead fields in the React UI (making calls to the local MySQL DB)
    class TemporariesController < BaseApiController
      # POST api/v3/simulations
      def simulations
        DmpIdService.simulate_works(dmp_id: params[:dmp_id], works_count: params[:nbr_works],
                                    include_grant: %w[1 true on].include?(params[:grant]&.to_s&.downcase))
      end
    end
  end
end
