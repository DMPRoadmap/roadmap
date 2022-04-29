# frozen_string_literal: true

module Paginable
  # Controller for paginating/sorting/searching the registries table
  class RegistriesController < ApplicationController
    include Paginable

    # /paginable/registries/index/:page
    def index
      authorize(Registry)
      paginable_renderise(
        partial: 'index',
        scope: Registry.all,
        query_params: { sort_field: 'registries.name', sort_direction: :asc },
        format: :json
      )
    end
  end
end
