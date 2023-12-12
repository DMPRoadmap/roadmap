# frozen_string_literal: true

require 'jsonpath'

module Api
  module V1
    module Madmp
      # Handles CRUD operations for Services in API V1
      class ServicesController < BaseApiController
        before_action :authorize_request, except: %i[ror orcid loterre]

        respond_to :json

        # GET /api/v1/service/ror?query=:query&filter=:filter
        def ror
          render json: MadmpExternalApis::RorService.search(
            term: params[:query],
            filters: params[:filter]&.split(',')
          )
        end

        # GET /api/v1/service/orcid?search=:search&rows=:rows
        # :search can be an orcid id or name
        def orcid
          render json: MadmpExternalApis::OrcidService.search(
            term: params[:search],
            rows: params[:rows]
          )
        end

        # GET /api/v1/madmp/services/loterre/{endpoint}[query_parameters]
        # :endpoint Loterre endpoint
        # :params query parameters
        def loterre
          render json: MadmpExternalApis::LoterreService.request(
            query_params: request.query_parameters,
            params:
          )
        end
      end
    end
  end
end
