# frozen_string_literal: true

module Api
  module V3
    # Endpoints that proxy calls to other external systems
    class ProxiesController < BaseApiController
      MSG_DMP_ID_REGISTRATION_FAILED = 'Unable to register a DMP ID at this time.'

      # GET /api/v3/awards/crossref/{:fundref_id}?{query_string_args}
      #        Allows the following query string arguments:
      #          keywords={words}&project={project}&opportunity={opportunity}&pi_names={pi_names}&years={years}
      #          &page={page}&per_page={per}
      def crossref_awards
        target = "awards/crossref/#{params[:fundref_id]}"
        results = ExternalApis::DmphubService.proxied_award_search(api_target: target, args: args_from_params)
        @items = paginate_response(results: results)
        render json: render_to_string(template: '/api/v3/proxies/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::ProxiesController.crossref_awards #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # GET /api/v3/awards/nih?{query_string_args}
      #        Allows the following query string arguments:
      #          keywords={words}&project={project}&opportunity={opportunity}&pi_names={pi_names}&years={years}
      #          &page={page}&per_page={per}
      def nih_awards
        target = 'awards/nih'
        results = ExternalApis::DmphubService.proxied_award_search(api_target: target, args: args_from_params)
        @items = paginate_response(results: results)
        render json: render_to_string(template: '/api/v3/proxies/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::ProxiesController.nih_awards #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # GET /api/v3/awards/nsf?{query_string_args}
      #        Allows the following query string arguments:
      #          keywords={words}&project={project}&opportunity={opportunity}&pi_names={pi_names}&years={years}
      #          &page={page}&per_page={per}
      def nsf_awards
        target = 'awards/nsf'
        results = ExternalApis::DmphubService.proxied_award_search(api_target: target, args: args_from_params)
        @items = paginate_response(results: results)
        render json: render_to_string(template: '/api/v3/proxies/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::ProxiesController.nsf_awards #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # POST /api/v3/dmps/{:id}/register
      #        Register the DMP ID for the specified Work in Progress (WIP) DMP
      def register_dmp_id
        dmp = Dmp.find_by(id: params[:id])
        render_error(errors: DmpsController::MSG_DMP_NOT_FOUND, status: :not_found) and return if dmp.nil?
        render_error(errors: DmpsController::MSG_DMP_UNAUTHORIZED, status: :unauthorized) and return unless dmp.user == current_user

        dmp.narrative.attach(params[:dmp][:narrative]) if params.fetch(:dmp, {})[:narrative].present?
        dmp.save

        # Call the DMPHub to register the DMP ID and upload the narrative PDF (performed async by ActiveJob)
        dmp_id = DmpIdService.mint_dmp_id(plan: dmp)
        render_error(errors: MSG_DMP_ID_REGISTRATION_FAILED, status: :bad_request) and return unless dmp_id.is_a?(Identifier)

        # Add the DMP ID to the Dmp record
        dmp.update(dmp_id: dmp_id.value)
        # Send the Narrative PDF
        PdfPublisherJob.perform_now(plan: dmp)

        # Fetch the DMP ID record
        result = DmpIdService.fetch_dmp_id(dmp_id: dmp_id.value)
        render_error(errors: MSG_DMP_ID_REGISTRATION_FAILED, status: :server_error) and return unless result.is_a?(Hash)

        @items = paginate_response(results: [result])
        render json: render_to_string(template: '/api/v3/proxies/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::ProxiesController.register_dmp_id #{e.message}"
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
    end
  end
end
