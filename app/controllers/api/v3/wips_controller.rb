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

puts '========================'
puts params
puts '------------------------'
puts wip_params
puts '------------------------'
puts narrative_params
puts '========================'

        wip = Wip.new(user: current_user, metadata: { dmp: wip_params })
        # Attach the narrative PDF if applicable
        wip.narrative = narrative_params if narrative_params.present?

        if wip.save
          @wips = [wip]
          render json: render_to_string(template: '/api/v3/wips/index'), status: :created
        else
puts "FAIL #{wip.errors.full_messages}"

          @payload = { errors: [wip.errors.full_messages] }
          render json: render_to_string(template: '/api/v3/error'), status: :bad_request
        end
      rescue ActionController::ParameterMissing => e

puts "NO PARAM: #{e.message}"

        @payload = { errors: ["Invalid request #{::Wip::INVALID_JSON_MSG}"] }
        render json: render_to_string(template: '/api/v3/error'), status: :bad_request
      end

      # GET /dmps/{:id}
      def show
        wip = Wip.find_by(identifier: params[:id])
        render_error(errors: MSG_WIP_NOT_FOUND, status: :not_found) and return if wip.nil?
        render_error(errors: MSG_WIP_UNAUTHORIZED, status: :unauthorized) and return unless wip.user == current_user

        @wips = [wip]
        render json: render_to_string(template: '/api/v3/wips/index'), status: :ok
      end

      # PUT /dmps/{:id}
      def update
        wip = Wip.find_by(identifier: params[:id])
        render_error(errors: MSG_WIP_NOT_FOUND, status: :not_found) and return if wip.nil?
        render_error(errors: MSG_WIP_UNAUTHORIZED, status: :unauthorized) and return unless wip.user == current_user

        if wip.update(metadata: { dmp: wip_params })
          @wips = [wip]
          render json: render_to_string(template: '/api/v3/wips/index'), status: :ok
        else
          @payload = { errors: [wip.errors.full_messages] }
          render json: render_to_string(template: '/api/v3/error'), status: :bad_request
        end
      rescue ActionController::ParameterMissing => e
        @payload = { errors: ["Invalid request #{::Wip::INVALID_JSON_MSG}"] }
        render json: render_to_string(template: '/api/v3/error'), status: :bad_request
      end

      # DELETE /dmps/{:id}
      def destroy
        wip = Wip.find_by(identifier: params[:id])
        render_error(errors: MSG_WIP_NOT_FOUND, status: :not_found) and return if wip.nil?
        render_error(errors: MSG_WIP_UNAUTHORIZED, status: :unauthorized) and return unless wip.user == current_user

        if wip.destroy
          @wips = []
          render json: render_to_string(template: '/api/v3/wips/index'), status: :ok
        else
          @payload = { errors: [wip.errors.full_messages] }
          render json: render_to_string(template: '/api/v3/error'), status: :bad_request
        end
      end

      # GET /dmps/{:id}/narrative
      def narrative
        wip = Wip.find_by(identifier: params[:id])
        render_error(errors: MSG_WIP_NOT_FOUND, status: :not_found) and return if wip.nil?
        render_error(errors: MSG_WIP_UNAUTHORIZED, status: :unauthorized) and return unless wip.user == current_user

        file_name = wip.narrative_file_name.end_with?('.pdf') ? wip.narrative_file_name : "#{wip.narrative_file_name}.pdf"
        send_data(wip.narrative_content, type: 'application/pdf', filename: file_name, disposition: 'inline')
      end

      private

      def wip_params
        params.require(:dmp).permit(dmp_permitted_params).to_h
      end

      def narrative_params
        params.permit(narrative: [data: [:content_type, :original_filename, :tempfile]])
      end
    end
  end
end
