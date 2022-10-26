# frozen_string_literal: true

module Paginable
  # Controller for paginating/sorting/searching the guidance groups table
  class GuidanceGroupsController < ApplicationController
    include Paginable

    # /paginable/guidance_groups/index/:page
    def index
      authorize(Guidance)
      paginable_renderise(
        partial: 'index',
        scope: GuidanceGroup.includes(:org).by_org(current_user.org),
        query_params: { sort_field: 'guidance_groups.name', sort_direction: :asc },
        format: :json
      )
    end
  end
end
