# frozen_string_literal: true

module Paginable

  class ApiLogsController < ApplicationController

    after_action :verify_authorized
    respond_to :html

    include Paginable

    # GET /paginable/api_logs/:page
    def index
      authorize(ApiClient)
      @api_logs = ApiLog.all
      paginable_renderise(
        partial: "index",
        scope: ApiLog.all,
        query_params: { sort_field: "api_logs.created_at", sort_direction: :desc },
        format: :json
      )
    end

  end

end
