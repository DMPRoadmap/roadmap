# frozen_string_literal: true

module Api
  module V3
    # Endpoints for Draft DMPs
    class DraftsController < BaseApiController
      MSG_DMP_ID_REGISTRATION_FAILED = 'Unable to register a DMP ID at this time.'
      MSG_DMP_ID_TOMBSTONE_FAILED = 'Unable to tombstone this DMP ID.'
      MSG_DMP_ID_UPDATE_FAILED = 'Unable to update the DMP ID metadata.'
      MSG_INVALID_DMP_ID = 'Invalid DMP ID, expected JSON data.'
      MSG_DMP_NOT_FOUND = 'DMP not found.'
      MSG_DMP_UNAUTHORIZED = 'Not authorized to modify the DMP.'

      # GET /drafts
      def index
        @drafts = DraftsPolicy::Scope.new(current_user, Draft.new).resolve
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DraftsController.index #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # POST /drafts
      def create
        # Extract the narrative PDF so we can add it to ActiveStorage
        args = create_params
        args.delete(:narrative)
        dmp = Draft.new(user: current_user, metadata: { dmp: args })

        # Attach the narrative PDF if applicable
        dmp.narrative.attach(create_params[:narrative]) if create_params[:narrative].present?
        if dmp.save
          @drafts = [dmp]
          render json: render_to_string(template: '/api/v3/drafts/index'), status: :created
        else
          render_error(errors: dmp.errors.full_messages, status: :bad_request)
        end
      rescue ActionController::ParameterMissing => e
        render_error(errors: "Invalid request #{Draft::INVALID_JSON_MSG}", status: :bad_request)
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DraftsController.create #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # GET /drafts/{:id}
      def show
        dmp = Draft.find_by(draft_id: params[:id])
        render_error(errors: MSG_DMP_NOT_FOUND, status: :not_found) and return if dmp.nil?
        render_error(errors: MSG_DMP_UNAUTHORIZED, status: :unauthorized) and return unless dmp.user == current_user

        @drafts = [dmp]
        render json: render_to_string(template: '/api/v3/drafts/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DraftsController.show #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # PUT /drafts/{:id}
      def update
        dmp = Draft.find_by(draft_id: params[:id])
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
          @drafts = [dmp]
          render json: render_to_string(template: '/api/v3/drafts/index'), status: :ok
        else
          render_error(errors: dmp.errors.full_messages, status: :bad_request)
        end
      rescue ActionController::ParameterMissing => e
        render_error(errors: "Invalid request #{Draft::INVALID_JSON_MSG}", status: :bad_request)
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DraftsController.update #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # DELETE /drafts/{:id}
      def destroy
        dmp = Draft.find_by(draft_id: params[:id])
        render_error(errors: MSG_DMP_NOT_FOUND, status: :not_found) and return if dmp.nil?
        render_error(errors: MSG_DMP_UNAUTHORIZED, status: :unauthorized) and return unless dmp.user == current_user

        # Narrative PDF will be automatically removed
        if dmp.destroy
          @drafts = []
          render json: render_to_string(template: '/api/v3/drafts/index'), status: :ok
        else
          render_error(errors: dmp.errors.full_messages, status: :bad_request)
        end
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::DraftsController.destroy #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      private

      # Create params come through as multipart/form-data and I'm having trouble getting the top level :dmp to work
      # so we have specific params for the create action
      def create_params
        params.permit(:title, :narrative)
      end

      def dmp_params
        params.require(:dmp).permit(:narrative, :remove_narrative, dmp_permitted_params)
      end
    end
  end
end
