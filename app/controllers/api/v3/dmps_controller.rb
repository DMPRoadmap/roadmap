# frozen_string_literal: true

module Api
  module V3
    # Endpoints that proxy calls to the DMPHub for DMP ID management
    class DmpsController < BaseApiController
      # POST /api/v3/dmps/{:id}/register
      #        Register the DMP ID for the specified draft DMP
      def create
        dmp = Draft.find_by(id: params[:id])
        render_error(errors: DmpsController::MSG_DMP_NOT_FOUND, status: :not_found) and return if dmp.nil?
        render_error(errors: DmpsController::MSG_DMP_UNAUTHORIZED, status: :unauthorized) and return unless dmp.user == current_user

        result = dmp.register_dmp_id!
        render_error(errors: DmpsController::MSG_DMP_ID_REGISTRATION_FAILED, status: :bad_request) and return if result.nil?

        @items = paginate_response(results: [result])
        render json: render_to_string(template: '/api/v3/proxies/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::ProxiesController.create #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # GET /api/v3/dmps
      def index
        dmps = DmpIdService.fetch_dmps(user: current_user)
        render_error(errors: DmpsController::MSG_DMP_NOT_FOUND, status: :not_found) and return unless dmps.is_a?(Array) &&
                                                                                                      dmps.any?

        @items = paginate_response(results: dmps)
        render json: render_to_string(template: '/api/v3/proxies/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::ProxiesController.index #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # GET /api/v3/dmps/{:id}
      def show
        dmp = DmpIdService.fetch_dmp_id(dmp_id: params[:id])
        render_error(errors: DmpsController::MSG_DMP_NOT_FOUND, status: :not_found) and return if dmp.nil?

        @items = paginate_response(results: [dmp])
        render json: render_to_string(template: '/api/v3/proxies/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::ProxiesController.show #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # PUT /api/v3/dmps/{:id}
      def update
        dmp = DmpIdService.fetch_dmp_id(dmp_id: params[:id])
        render_error(errors: DmpsController::MSG_DMP_NOT_FOUND, status: :not_found) and return if dmp.nil?

        authed = user_is_authorized(dmp: dmp)
        render_error(errors: DmpsController::MSG_DMP_UNAUTHORIZED, status: :unauthorized) and return unless authed

        json = JSON.parse(dmp_permitted_params.to_h.to_json)
        result = DmpIdService.update_dmp_id(plan: json)
        render_error(errors: DmpsController::MSG_DMP_ID_UPDATE_FAILED, status: :bad_request) and return if result.nil?

        @items = paginate_response(results: [result])
        render json: render_to_string(template: '/api/v3/proxies/index'), status: :ok
      rescue JSON::ParserError => e
        Rails.logger.error "Failure in Api::V3::ProxiesController.register_dmp_id #{e.message}"
        render_error(errors: MSG_INVALID_DMP_ID, status: 400)
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::ProxiesController.update #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # DELETE /api/v3/dmps/{:id}
      def destroy
        dmp = DmpIdService.fetch_dmp_id(dmp_id: params[:id])
        render_error(errors: DmpsController::MSG_DMP_NOT_FOUND, status: :not_found) and return if dmp.nil?
        render_error(errors: MSG_SERVER_ERROR, status: 500) unless dmp[:dmp_id][:identifier].present?

        authed = user_is_authorized(dmp: dmp)
        render_error(errors: DmpsController::MSG_DMP_UNAUTHORIZED, status: :unauthorized) and return unless authed

        # For now a user can only hide a DMP from their dashboard
        # result = DmpIdService.delete_dmp_id(plan: json)
        # render_error(errors: DmpsController::MSG_DMP_ID_TOMBSTONE_FAILED, status: :bad_request) and return if result.nil?
        HiddenDmp.find_or_create_by(user: current_user, dmp_id: dmp[:dmp_id][:identifier])

        @items = paginate_response(results: ['The DMP has been hidden for this user.'])
        render json: render_to_string(template: '/api/v3/proxies/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::ProxiesController.destroy #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      private

      def awards_params
        params.permit(:keywords, :project, :opportunity, :pi_names, :years, :page, :per_page)
      end

      def args_from_params
        args = {}
        awards_params.to_h.each do |key, val|
          args[key] = val.downcase.strip.gsub(/\s/, '+')
        end
        args
      end

      # Check to make sure the current user is authorized to update/tombstone the DMP ID
      def user_is_authorized(dmp:)
        return false unless dmp.is_a?(Hash) && dmp['contact'].present? && current_user.present? && current_user.can_org_admin?

        current_org = current_user.org&.identifier_for_scheme(scheme: 'ror')
        orgs = [dmp.fetch('contact', {}).fetch('dmproadmap_affiliation', {}).fetch('affiliation_id', {})['identifier']]
        dmp.fetch('contributor', []).each do |contrib|
          orgs << contrib.fetch('dmproadmap_affiliation', {}).fetch('affiliation_id', {})['identifier']
        end
        orgs = orgs.map { |ror| ror.to_s.downcase.strip }.flatten.compact.uniq
        orgs.include?(current_org)
      end
    end
  end
end
