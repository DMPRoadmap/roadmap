# frozen_string_literal: true

module Paginable
  # Controller for paginating/sorting/searching the registry values table
  class RegistryValuesController < ApplicationController
    include Paginable

    # GET /paginable/registry_values/index/:page
    def index
      authorize(RegistryValue)
      paginable_renderise(
        partial: 'index',
        scope: RegistryValue.where(registry_id: params[:id]),
        locals: { registry_id: params[:id] },
        query_params: { sort_field: 'registry_values.order', sort_direction: :asc },
        format: :json
      )
    end
  end
end
