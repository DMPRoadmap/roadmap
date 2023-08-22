# frozen_string_literal: true

module Api
  module V3
    # Endpoints that proxy calls to the DMPHub for citation retrieval
    class CitationsController < BaseApiController
      MSG_MISSING_DOI = 'Expected `{"dmproadmap_related_identifier": {"type": "dataset","value":"11.2222/3333"}}`'

      # POST /api/v3/citations
      def fetch_citation
        doi = citation_params[:dmproadmap_related_identifier].to_h
        is_doi = doi.fetch(:type, 'doi').downcase.strip == 'doi'
        # The citation fetching process is slow, so don't allow more than 3 at a time!
        render_error(errors: 'Item already has a citation.', status: 400) and return if doi[:citation].present?
        render_error(errors: 'Can only fetch citations for DOIs.', status: 400) and return unless is_doi
        render_error(errors: MSG_MISSING_DOI, status: 400) and return if doi.nil?

        result = ExternalApis::DmphubService.fetch_citation(related_identifier: doi)
        @items = paginate_response(results: result.nil? ? [] : [result])
        render json: render_to_string(template: '/api/v3/proxies/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::CitationsController.fetch_citation #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      private

      def citation_params
        params.permit(dmproadmap_related_identifier: [:work_type, :value, :descriptor, :citation, :type])
      end
    end
  end
end
