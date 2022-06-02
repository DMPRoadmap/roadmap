# frozen_string_literal: true

module Dmpopidor
  # Customized code for ContributorsController
  module ContributorsController
    # GET /plans/:plan_id/contributors
    # CHANGES: Contributors Tab uses maDMP Fragments
    def index
      authorize @plan
      @dmp_fragment = @plan.json_fragment
      @contributors = @dmp_fragment.persons.order("data->>'firstName', data->>'lastName'")
    end
  end
end
