# frozen_string_literal: true

class Paginable::RegistryValuesController < ApplicationController

  include Paginable

  # GET /paginable/registry_values/index/:page
  def index
    authorize(RegistryValue)
    paginable_renderise(
      partial: "index",
      scope: RegistryValue.where(registry_id: params[:id]),
      locals: { registry_id: params[:id] },
      query_params: { sort_field: "registry_values.order", sort_direction: :asc },
    )
  end

end
