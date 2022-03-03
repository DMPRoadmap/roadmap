# frozen_string_literal: true

module Paginable
  # Controller for paginating/sorting/searching the madmp_schema table
  class MadmpSchemasController < ApplicationController
    include Paginable

    # /paginable/madmp_schemas/index/:page
    def index
      authorize(MadmpSchema)
      paginable_renderise(
        partial: 'index',
        scope: MadmpSchema.paginable,
        query_params: { sort_field: 'madmp_schemas.name', sort_direction: :asc },
        format: :json
      )
    end
  end
end
