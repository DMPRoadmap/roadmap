# frozen_string_literal: true

module Api
  module V3
    # Endpoints for Work in Progress (WIP) DMPs
    class WipsController < BaseApiController
      MSG_WIP_NOT_FOUND = 'DMP not found'
      MSG_WIP_UNAUTHORIZED = 'Not authorized to modify the DMP'

      # GET /dmps
      def index
        @wips = WipsPolicy::Scope.new(current_user, Wip.new).resolve
      end

      # POST /dmps
      def create
        wip = Wip.new(user: current_user, metadata: { dmp: wip_params })
        if wip.save
          @wips = [wip]
          render json: render_to_string(template: '/api/v3/wips/index'), status: :created
        else
          render_error(errors: wip.errors.full_messages, status: :bad_request)
        end
      rescue ActionController::ParameterMissing => e
        render_error(errors: "Invalid request #{::Wip::INVALID_JSON_MSG}", status: :bad_request)
      end

      # GET /dmps
      def show
        wip = Wip.find_by(identifier: params[:id])
        render_error(errors: MSG_WIP_NOT_FOUND, status: :not_found) and return if wip.nil?
        render_error(errors: MSG_WIP_UNAUTHORIZED, status: :unauthorized) and return unless wip.user == current_user

        @wips = [wip]
        render json: render_to_string(template: '/api/v3/wips/index'), status: :ok
      end

      # PUT /dmps
      def update
        wip = Wip.find_by(identifier: params[:id])
        render_error(errors: MSG_WIP_NOT_FOUND, status: :not_found) and return if wip.nil?
        render_error(errors: MSG_WIP_UNAUTHORIZED, status: :unauthorized) and return unless wip.user == current_user

        if wip.update(metadata: { dmp: wip_params })
          @wips = [wip]
          render json: render_to_string(template: '/api/v3/wips/index'), status: :ok
        else
          render_error(errors: wip.errors.full_messages, status: :bad_request)
        end
      rescue ActionController::ParameterMissing => e
        render_error(errors: "Invalid request #{::Wip::INVALID_JSON_MSG}", status: :bad_request)
      end

      # DELETE /dmps
      def destroy
        wip = Wip.find_by(identifier: params[:id])
        render_error(errors: MSG_WIP_NOT_FOUND, status: :not_found) and return if wip.nil?
        render_error(errors: MSG_WIP_UNAUTHORIZED, status: :unauthorized) and return unless wip.user == current_user

        if wip.destroy
          @wips = []
          render json: render_to_string(template: '/api/v3/wips/index'), status: :ok
        else
          render_error(errors: wip.errors.full_messages, status: :bad_request)
        end
      end

      private

      def wip_params
        params.require(:dmp).permit(dmp_permitted_params).to_h
      end
    end
  end
end
