# frozen_string_literal: true

module Paginable
  # Controller for paginating/sorting/searching the guidance table
  class GuidancesController < ApplicationController
    include Paginable

    # /paginable/guidances/index/:page
    def index
      authorize(Guidance)
      paginable_renderise(
        partial: 'index',
        scope: Guidance.includes(:guidance_group, :themes).by_org(current_user.org),
        query_params: { sort_field: 'guidances.text', sort_direction: :asc },
        format: :json
      )
    end
  end
end
