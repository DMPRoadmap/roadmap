# frozen_string_literal: true

module Dmpopidor

  module Controllers

    module Contributors

      # GET /plans/:plan_id/contributors
      def index
        authorize @plan
        @dmp_fragment = @plan.json_fragment
        @contributors = @dmp_fragment.persons
      end

      

    end

  end

end
