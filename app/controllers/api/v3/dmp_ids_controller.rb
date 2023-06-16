# frozen_string_literal: true

module Api
  module V3
    # Endpoints that proxy calls to the DMPHub for DMP ID management
    class DmpIdsController < BaseApiController

      # GET /api/v3/dmp_ids
      def index

        render json: render_to_string(template: '/api/v3/dmp_ids/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DmpIdsController.index #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # POST /api/v3/dmp_ids
      def create

        render json: render_to_string(template: '/api/v3/dmp_ids/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DmpIdsController.create #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # GET /api/v3/dmp_ids/{dmp_id}
      def show

        render json: render_to_string(template: '/api/v3/dmp_ids/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DmpIdsController.show #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # PUT /api/v3/dmp_ids/{dmp_id}
      def update

        render json: render_to_string(template: '/api/v3/dmp_ids/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DmpIdsController.update #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # DELETE /api/v3/dmp_ids/{dmp_id}
      def destroy

        render json: render_to_string(template: '/api/v3/dmp_ids/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DmpIdsController.destroy #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end
    end
  end
end
