# frozen_string_literal: true

module Api
  module V3
    # Endpoints for Work in Progress (WIP) DMPs
    class DmpsController < BaseApiController
      MSG_DMP_NOT_FOUND = 'DMP not found'
      MSG_DMP_UNAUTHORIZED = 'Not authorized to modify the DMP'

      # GET /dmps
      def index
        @dmps = DmpsPolicy::Scope.new(current_user, Dmp.new).resolve
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DmpsController.index #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # POST /dmps
      def create
        # Extract the narrative PDF so we can add it to ActiveStorage
        args = dmp_params
        args.delete(:narrative)

        dmp = Dmp.new(user: current_user, metadata: { dmp: args })
        # Attach the narrative PDF if applicable
        dmp.narrative.attach(dmp_params[:narrative]) if dmp_params[:narrative].present?
        if dmp.save
          @dmps = [dmp]
          render json: render_to_string(template: '/api/v3/dmps/index'), status: :created
        else
          render_error(errors: dmp.errors.full_messages, status: :bad_request)
        end
      rescue ActionController::ParameterMissing => e
        render_error(errors: "Invalid request #{::Dmp::INVALID_JSON_MSG}", status: :bad_request)
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DmpsController.create #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # GET /dmps/{:id}
      def show
        dmp = Dmp.find_by(identifier: params[:id])
        render_error(errors: MSG_DMP_NOT_FOUND, status: :not_found) and return if dmp.nil?
        render_error(errors: MSG_DMP_UNAUTHORIZED, status: :unauthorized) and return unless dmp.user == current_user

        @dmps = [dmp]
        render json: render_to_string(template: '/api/v3/dmps/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DmpsController.show #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # PUT /dmps/{:id}
      def update
        dmp = Dmp.find_by(identifier: params[:id])
        render_error(errors: MSG_DMP_NOT_FOUND, status: :not_found) and return if dmp.nil?
        render_error(errors: MSG_DMP_UNAUTHORIZED, status: :unauthorized) and return unless dmp.user == current_user

        # Extract the narrative PDF so we can add it to ActiveStorage
        args = dmp_params
        args.delete(:narrative)

        # Remove the old narrative if applicable
        dmp.narrative.purge if (dmp_params[:narrative].present? || dmp_params[:remove_narrative].present?) &&
                               dmp.narrative.attached?
        # Attach the narrative PDF if applicable
        dmp.narrative.attach(dmp_params[:narrative]) if dmp_params[:narrative].present?

        if dmp.update(metadata: { dmp: args })
          @dmps = [dmp]
          render json: render_to_string(template: '/api/v3/dmps/index'), status: :ok
        else
          render_error(errors: dmp.errors.full_messages, status: :bad_request)
        end
      rescue ActionController::ParameterMissing => e
        render_error(errors: "Invalid request #{::Dmp::INVALID_JSON_MSG}", status: :bad_request)
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DmpsController.update #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # DELETE /dmps/{:id}
      def destroy
        dmp = Dmp.find_by(identifier: params[:id])
        render_error(errors: MSG_DMP_NOT_FOUND, status: :not_found) and return if dmp.nil?
        render_error(errors: MSG_DMP_UNAUTHORIZED, status: :unauthorized) and return unless dmp.user == current_user

        # Narrative PDF will be automatically removed
        if dmp.destroy
          @dmps = []
          render json: render_to_string(template: '/api/v3/dmps/index'), status: :ok
        else
          render_error(errors: dmp.errors.full_messages, status: :bad_request)
        end
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DmpsController.destroy #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      private

      def dmp_params
        params.require(:dmp).permit(:narrative, :remove_narrative, dmp_permitted_params)# .to_h
      end
    end
  end
end
