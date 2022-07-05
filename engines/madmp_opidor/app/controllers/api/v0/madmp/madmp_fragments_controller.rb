# frozen_string_literal: true

require 'jsonpath'

module Api
  module V0
    module Madmp
      # Handles CRUD operations for MadmpFragments in API V0
      class MadmpFragmentsController < Api::V0::BaseController
        before_action :authenticate
        rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

        # rubocop:disable Metrics/AbcSize
        def show
          @fragment = MadmpFragment.find(params[:id])
          # check if the user has permissions to use the API
          raise Pundit::NotAuthorizedError unless Api::V0::Madmp::MadmpFragmentPolicy.new(@user, @fragment).show?

          fragment_data = if query_params[:mode] == 'fat'
                            @fragment.get_full_fragment(with_ids: true)
                          else
                            @fragment.data
                          end

          fragment_data = select_property(fragment_data, query_params[:property])

          render json: {
            'data' => fragment_data,
            'dmp_id' => @fragment.dmp_id,
            'schema' => @fragment.madmp_schema.schema
          }
        end
        # rubocop:enable Metrics/AbcSize

        def update
          @fragment = MadmpFragment.find(params[:id])

          # check if the user has permissions to use the API
          raise Pundit::NotAuthorizedError unless Api::V0::Madmp::MadmpFragmentPolicy.new(@user, @fragment).update?

          @fragment.import_with_ids(params[:data], @fragment.madmp_schema)

          render json: {
            'data' => @fragment.data,
            'dmp_id' => @fragment.dmp_id,
            'schema' => @fragment.madmp_schema.schema
          }
        end

        ## NEEDS ERROR MANAGEMENT
        # rubocop:disable Metrics/AbcSize
        def dmp_fragments
          @dmp_fragment = Fragment::Dmp.find(params[:id])
          @dmp_fragments = MadmpFragment.where(dmp_id: @dmp_fragment.id).order(:id).map do |f|
            {
              'id' => f.id,
              'data' => f.data,
              'schema' => f.madmp_schema.schema
            }
          end
          @dmp_fragments.unshift(
            {
              'id' => @dmp_fragment.id,
              'data' => @dmp_fragment.data,
              'schema' => @dmp_fragment.madmp_schema.schema
            }
          )
          render json: {
            'dmp_id' => @dmp_fragment.id,
            'data' => @dmp_fragments,
            'schema' => @dmp_fragment.madmp_schema.schema
          }
        end
        # rubocop:enable Metrics/AbcSize

        private

        def select_property(fragment_data, property_name)
          fragment_data = JsonPath.on(fragment_data, "$..#{property_name}") if property_name.present?
          fragment_data
        end

        def query_params
          params.permit(:mode, :property)
        end

        def record_not_found
          render json: {
            'error' => format(_("Fragment with id %{id} doesn't exist."), id: params[:id])
          }, status: 404
        end
      end
    end
  end
end
