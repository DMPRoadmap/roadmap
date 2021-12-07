# frozen_string_literal: true

module Api

  module V1

    module Madmp

      class RegistriesController < BaseApiController

        respond_to :json

        # GET /api/v1/madmp/registries
        def index
          registries = Registry.all.select(:id, :name)
          respond_with registries
        end

        # GET /api/v1/madmp/registries/:name
        def show
          begin
            registry = Registry.includes(:registry_values).find_by!(name: params[:name])
            render json: {
              "name" => registry.name,
              "values" => registry.registry_values.map(&:data)
            }
          rescue ActiveRecord::RecordNotFound
            render_error(errors: [_("Registry not found")], status: :not_found)
          end
        end

      end

    end

  end

end
