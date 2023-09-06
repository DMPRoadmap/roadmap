# frozen_string_literal: true

require 'jsonpath'

module Api
  module V1
    module Madmp
      # Handles CRUD operations for Services in API V1
      class ServicesController < BaseApiController
        before_action :authorize_request, except: %i[ror orcid]

        respond_to :json

        # GET /api/v1/service/ror?query=:query&filter=:filter
        def ror
          render json: MadmpExternalApis::RorService.search(
            term: params[:query],
            filters: params[:filter]&.split(',')
          )
        end

        # GET /api/v1/service/orcid?search=:search
        # :search can be an orcid id or name
        def orcid
          render json: MadmpExternalApis::OrcidService.search(
            term: params[:search]
          )
        end
      end
    end
  end
end
