# frozen_string_literal: true

module Api
  module V1
    module Madmp
      # Handles CRUD operations for MadmpSchemas in API V1
      class MadmpSchemasController < BaseApiController
        respond_to :json

        # GET /api/v1/madmp/schemas
        def index
          schemas = if params[:name].present?
                      MadmpSchema.find_by!(name: params[:name]).schema
                    else
                      MadmpSchema.all.pluck(:schema)
                    end
          respond_with schemas
        rescue ActiveRecord::RecordNotFound
          render_error(errors: [_('Schema not found')], status: :not_found)
        end

        # GET /api/v1/madmp/schemas
        def show
          @schema = MadmpSchema.find(params[:id])
          respond_with @schema.schema
        rescue ActiveRecord::RecordNotFound
          render_error(errors: [_('Schema not found')], status: :not_found)
        end
      end
    end
  end
end
