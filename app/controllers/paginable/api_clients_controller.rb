# frozen_string_literal: true

module Paginable
  # Handler for viewing API v2 logs
  class ApiClientsController < ApplicationController
    after_action :verify_authorized
    respond_to :html

    include Paginable

    # GET /paginable/api_clients/:page
    def index
      authorize(ApiClient)
      @api_clients = ApiClient.all
      paginable_renderise(
        partial: 'index',
        scope: @api_clients,
        query_params: { sort_field: 'api_clients.name', sort_direction: :asc },
        format: :json
      )
    end
  end
end
