# frozen_string_literal: true

class Paginable::StructuredDataSchemasController < ApplicationController

  include Paginable

  # /paginable/structured_data_schemas/index/:page
  def index
    authorize(StructuredDataSchema)
    paginable_renderise(
      partial: "index",
      scope: StructuredDataSchema.all,
      query_params: { sort_field: "structured_data_schemas.name", sort_direction: :asc })
  end

end
