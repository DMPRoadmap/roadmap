# frozen_string_literal: true

module Api
  module V0
    module Madmp
      # Handles CRUD operations for MadmpSchemas in API V0
      class MadmpSchemasController < Api::V0::BaseController
        before_action :authenticate

        def show
          @schema = MadmpSchema.find(params[:id])
          # check if the user has permissions to use the templates API
          raise Pundit::NotAuthorizedError unless Api::V0::Madmp::MadmpSchemaPolicy.new(@user, @fragment).show?

          respond_with @schema.schema
        end
      end
    end
  end
end
