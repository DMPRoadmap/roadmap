# frozen_string_literal: true

class Paginable::RegistriesController < ApplicationController

  include Paginable

  # /paginable/registries/index/:page
  def index
    authorize(Registries)
    paginable_renderise(
      partial: "index",
      scope: Registry.all,
      query_params: { sort_field: "registries.name", sort_direction: :asc })
  end

end
