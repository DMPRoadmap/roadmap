# frozen_string_literal: true

module SuperAdmin
  # Handler for viewing API v2 logs
  class ApiLogsController < ApplicationController
    respond_to :html

    helper PaginableHelper

    # GET /api_clients
    def index
      authorize(ApiClient)
      @api_logs = ApiLog.all.page(1)
    end
  end
end
