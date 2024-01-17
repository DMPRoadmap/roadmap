# frozen_string_literal: true

module Api
  module V3
    # Endpoints that supply radio button, select box options to the React UI
    class OptionsController < BaseApiController

      SIZABLE_OUTPUT_TYPES = %w[audiovisual sound image model_representation data_paper dataset text]

      # GET /api/v3/contributor_roles
      def contributor_roles
        roles = Contributor.new.all_roles.map do |role|
          {
            label: ContributorPresenter.role_symbol_to_string(symbol: role),
            value: role.to_s,
            default: Contributor.role_default == role.to_s
          }
        end
        @items = paginate_response(results: roles)
        render json: render_to_string(template: '/api/v3/options/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::OptionsController.contributor_roles #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # GET /api/v3/output_types
      def output_types
        matches = ResearchOutput.output_types
        matches = matches.map do |key, val|
          {
            label: key.capitalize.gsub('_', ' '),
            value: key.downcase.gsub(' ', '_'),
            allow_size_specification: SIZABLE_OUTPUT_TYPES.include?(key)
          }
        end
        @items = paginate_response(results: matches)
        render json: render_to_string(template: '/api/v3/output_types/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::OptionsController.output_types #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # GET /api/v3/related_work_types
      def related_work_types
        matches = RelatedIdentifier.work_types.reject { |typ| typ == 'output_management_plan' }
        matches = matches.map do |key, val|
          {
            label: key.capitalize.gsub('_', ' '),
            value: key.downcase.gsub(' ', '_')
          }
        end
        @items = paginate_response(results: matches)
        render json: render_to_string(template: '/api/v3/typeaheads/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::OptionsController.work_types #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end
    end
  end
end
