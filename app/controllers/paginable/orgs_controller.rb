# frozen_string_literal: true

module Paginable
  # Controller for paginating/sorting/searching the orgs table
  class OrgsController < ApplicationController
    include Paginable

    # /paginable/guidances/index/:page
    def index
      authorize(Org)
      paginable_renderise(
        partial: 'index',
        scope: Org.with_template_count_and_associations_check,
        query_params: { sort_field: 'orgs.name', sort_direction: :asc },
        format: :json
      )
    end
  end
end
