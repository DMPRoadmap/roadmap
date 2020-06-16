# frozen_string_literal: true

class Paginable::MadmpSchemasController < ApplicationController

  include Paginable

  # /paginable/madmp_schemas/index/:page
  def index
    authorize(MadmpSchema)
    paginable_renderise(
      partial: "index",
      scope: MadmpSchema.all,
      query_params: { sort_field: "madmp_schemas.name", sort_direction: :asc })
  end

end
