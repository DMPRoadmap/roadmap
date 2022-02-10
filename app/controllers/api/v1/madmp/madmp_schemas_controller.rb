# frozen_string_literal: true

module Api

  module V1

    module Madmp

      class MadmpSchemasController < BaseApiController

        respond_to :json

        # GET /api/v1/madmp/schemas
        def index
          schemas = MadmpSchema.all.pluck(:schema)
          respond_with schemas
        end

        # GET /api/v1/madmp/schemas
        def show
          @schema = MadmpSchema.find(params[:id])
          respond_with @schema.schema
        rescue ActiveRecord::RecordNotFound
          render_error(errors: [_("Schema not found")], status: :not_found)
        end

      end

    end

  end

end
