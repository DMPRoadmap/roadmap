# frozen_string_literal: true

class  Paginable::ApiClientsController < ApplicationController

  after_action :verify_authorized
  respond_to :html

  include Paginable

  # /paginable/api_clients/index/:page
  def index
    authorize ApiClient
    paginable_renderise(
      partial: "index",
      scope: ApiClient.all,
      query_params: { sort_field: "api_clients.name", sort_direction: :asc }
    )
  end

end
