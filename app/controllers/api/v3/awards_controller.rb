# frozen_string_literal: true

module Api
  module V3
    # Endpoints that proxy calls to the DMPHub to search for grant/award information
    class AwardsController < BaseApiController
      # GET /api/v3/awards/crossref/{:fundref_id}?{query_string_args}
      #        Allows the following query string arguments:
      #          keywords={words}&project={project}&opportunity={opportunity}&pi_names={pi_names}&years={years}
      #          &page={page}&per_page={per}
      def crossref
        fundref = params.fetch(:fundref_id, '').gsub('10.13039/', '')
        target = "awards/crossref/#{fundref}"
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
      def nih
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
      def nsf
        target = 'awards/nsf'
        results = ExternalApis::DmphubService.proxied_award_search(api_target: target, args: args_from_params)
        @items = paginate_response(results: results)
        render json: render_to_string(template: '/api/v3/proxies/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::ProxiesController.nsf_awards #{e.message}"
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
