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
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::WipsController.index #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # POST /dmps
      def create
        args = @json.with_indifferent_access.fetch(:dmp, {})
        render_error(errors: wip.errors.full_messages, status: :bad_request) and return unless args[:title].present?

        # Extract the narrative PDF so we can add it to ActiveStorage
        narrative = args[:narrative] if args[:narrative].present?
        args.delete(:narrative) if args[:narrative].present?

        wip = Wip.new(user: current_user, metadata: { dmp: args })
        # Attach the narrative PDF if applicable
        wip.narrative.attach(narrative) if narrative.present? && narrative == ActionDispatch::Http::UploadedFile
        if wip.save
          @wips = [wip]
          render json: render_to_string(template: '/api/v3/wips/index'), status: :created
        else
          render_error(errors: wip.errors.full_messages, status: :bad_request)
        end
      rescue ActionController::ParameterMissing => e
        render_error(errors: "Invalid request #{::Wip::INVALID_JSON_MSG} - #{e.message}", status: :bad_request)
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::WipsController.create #{e.message}"
        Rails.logger.error e.backtrace
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # GET /dmps/{:id}
      def show
        wip = Wip.find_by(identifier: params[:id])
        render_error(errors: MSG_WIP_NOT_FOUND, status: :not_found) and return if wip.nil?
        render_error(errors: MSG_WIP_UNAUTHORIZED, status: :unauthorized) and return unless wip.user == current_user

        @wips = [wip]
        render json: render_to_string(template: '/api/v3/wips/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::WipsController.show #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # PUT /dmps/{:id}
      def update
        wip = Wip.find_by(identifier: params[:id])
        render_error(errors: MSG_WIP_NOT_FOUND, status: :not_found) and return if wip.nil?
        render_error(errors: MSG_WIP_UNAUTHORIZED, status: :unauthorized) and return unless wip.user == current_user

        # Extract the narrative PDF so we can add it to ActiveStorage
        args = wip_params
        args.delete(:narrative)

        # Remove the old narrative if applicable
        wip.narrative.purge if (wip_params[:narrative].present? || wip_params[:remove_narrative].present?) &&
                               wip.narrative.attached?
        # Attach the narrative PDF if applicable
        wip.narrative.attach(wip_params[:narrative]) if wip_params[:narrative].present?

        if wip.update(metadata: { dmp: args })
          @wips = [wip]
          render json: render_to_string(template: '/api/v3/wips/index'), status: :ok
        else
          render_error(errors: wip.errors.full_messages, status: :bad_request)
        end
      rescue ActionController::ParameterMissing => e
        render_error(errors: "Invalid request #{::Wip::INVALID_JSON_MSG}", status: :bad_request)
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::WipsController.update #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # DELETE /dmps/{:id}
      def destroy
        wip = Wip.find_by(identifier: params[:id])
        render_error(errors: MSG_WIP_NOT_FOUND, status: :not_found) and return if wip.nil?
        render_error(errors: MSG_WIP_UNAUTHORIZED, status: :unauthorized) and return unless wip.user == current_user

        # Narrative PDF will be automatically removed
        if wip.destroy
          @wips = []
          render json: render_to_string(template: '/api/v3/wips/index'), status: :ok
        else
          render_error(errors: wip.errors.full_messages, status: :bad_request)
        end
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::WipsController.destroy #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      private

      def wip_params
        params.require(:dmp).permit(:narrative, :remove_narrative, dmp_permitted_params).to_h
      end
    end
  end
end
