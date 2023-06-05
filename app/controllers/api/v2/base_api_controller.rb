# frozen_string_literal: true

module Api
  module V2
    # Generic helper methods for all API V2 controllers
    class BaseApiController < ApplicationController
      # We use the Doorkeeper gem to provide OAuth2 provider functionality for this application. An
      # ApiClient is able to access this API via:
      #   - :client_credentials - which allows them to access publicly accessible data
      #   - :authorization_code - to gain authorization from a User to access their data
      #
      # See the API wiki for full details: https://github.com/CDLUC3/dmptool/wiki/api-documentation
      include ::Doorkeeper::Helpers::Controller

      respond_to :json

      # Skipping the standard Rails authenticity tokens passed in UI
      skip_before_action :verify_authenticity_token

      # Parse the Doorkeeper token to get the APIClient and User
      before_action :authorize_request, except: %i[heartbeat me]
      before_action :parse_doorkeeper_token

      # Prep default instance variables for views
      before_action :base_response_content
      before_action :pagination_params, except: %i[heartbeat me]

      # Parse the incoming JSON
      before_action :parse_request, only: %i[create update]

      # Record the API access
      after_action :log_access, except: %i[heartbeat]

      attr_reader :client, :resource_owner

      # GET /api/v2/heartbeat
      # ---------------------
      # Used as a status check for external systems to determine if we are online (does not require auth)
      def heartbeat
        render '/api/v2/heartbeat', status: :ok
      end

      # Used to retrieve the currently logged in user
      def me
        render '/api/v2/me', status: :ok
      end

      protected

      # Generic handler for sending an error back to the caller
      def render_error(errors:, status: :bad_request)
        @payload = { errors: [errors] }
        render '/api/v2/error', status: status
      end

      # Paginate the response
      def paginate_response(results:)
        results = Kaminari.paginate_array(results) if results.is_a?(Array)
        results = results.page(@page).per(@per_page)
        @total_items = results.total_count
        results
      end

      private

      attr_accessor :json

      # =============
      # = Callbacks =
      # =============

      # Only requests with a valid Doorkeeper token are acceptable
      def authorize_request
        return true if doorkeeper_token.present?

        render_error(errors: 'token is invalid, expired or has been revoked', status: :unauthorized)
      end

      # Extract the ApiClient (aka Application), User (aka Resource Owner) and Scopes from Doorkeeper AccessToken
      def parse_doorkeeper_token
        return nil unless doorkeeper_token

        @client = ApiClient.find_by(id: doorkeeper_token.application_id)

        @resource_owner = User.includes(:plans, :access_grants)
                              .find_by(id: doorkeeper_token.resource_owner_id)

        @scopes = doorkeeper_token.scopes
      end

      # Set the generic application and caller variables used in all responses
      def base_response_content
        @application = ApplicationService.application_name
        @caller = request.remote_ip if @client.blank?
        @caller = @client.is_a?(User) ? @client.name(false) : @client.name if @client.present?
      end

      # Retrieve the requested pagination params or use defaults
      # only allow 100 per page as the max
      def pagination_params
        max_per_page = Rails.configuration.x.application.api_max_page_size
        @page = params.fetch('page', 1).to_i
        @per_page = params.fetch('per_page', max_per_page).to_i
        @per_page = max_per_page if @per_page > max_per_page
      end

      # Parse the body of the incoming request
      # rubocop:disable Metrics/AbcSize
      def parse_request
        return false unless request.present? && request.body.present?

        body = request.body.read
        @json = JSON.parse(body).with_indifferent_access
      rescue JSON::ParserError => e
        Rails.logger.error "API V2 - JSON Parser: #{e.message}"
        Rails.logger.error request.body
        render_error(errors: _('Invalid JSON format'), status: :bad_request)
        false
      end
      # rubocop:enable Metrics/AbcSize

      # Record the activity
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def log_activity(subject:, change_type:)
        return false unless @client.present? && subject.present? && change_type.present? &&
                            @client.is_a?(ApiClient) &&
                            ApiLog.change_types.key?(change_type.to_s)

        activity = case change_type.to_sym
                   when :added
                     "Created a new #{subject.class.name}:<br>%{subject}"
                   when :removed
                     "Deleted a #{subject.class.name}:<br>%{subject}"
                   else
                     "Modified a #{subject.class.name}:<br>%{changes}"
                   end

        changes = subject.changed? ? subject.previous_changes&.inspect : subject.changes&.inspect
        activity = format(activity, subject: subject.inspect, changes: changes)

        ApiLog.create(api_client_id: @client.id, logable: subject, change_type: change_type,
                      activity: activity)
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # Record the timestamp
      def log_access
        return false if @client.blank?

        @client.update(last_access: Time.zone.now) if @client.is_a?(ApiClient)
        @client.update(last_api_access: Time.zone.now) if @client.is_a?(User)
        true
      end

      # =========================
      # PERMIITTED PARAMS HEPERS
      # =========================

      def plan_permitted_params
        %i[created title description language ethical_issues_exist
           ethical_issues_description ethical_issues_report] +
          [dmp_ids: identifier_permitted_params,
           contact: contributor_permitted_params,
           contributors: contributor_permitted_params,
           costs: cost_permitted_params,
           project: project_permitted_params,
           datasets: dataset_permitted_params]
      end

      def identifier_permitted_params
        %i[type identifier]
      end

      def contributor_permitted_params
        %i[firstname surname mbox role] +
          [affiliations: affiliation_permitted_params,
           contributor_ids: identifier_permitted_params]
      end

      def affiliation_permitted_params
        %i[name abbreviation] +
          [affiliation_ids: identifier_permitted_params]
      end

      def cost_permitted_params
        %i[title description value currency_code]
      end

      def project_permitted_params
        %i[title description start_on end_on] +
          [funding: funding_permitted_params]
      end

      def funding_permitted_params
        %i[name funding_status] +
          [funder_ids: identifier_permitted_params,
           grant_ids: identifier_permitted_params]
      end

      def dataset_permitted_params
        %i[title description type issued language personal_data sensitive_data
           keywords data_quality_assurance preservation_statement] +
          [dataset_ids: identifier_permitted_params,
           metadata: metadatum_permitted_params,
           security_and_privacy_statements: security_and_privacy_statement_permitted_params,
           technical_resources: technical_resource_permitted_params,
           distributions: distribution_permitted_params]
      end

      def metadatum_permitted_params
        %i[description language] + [identifier: identifier_permitted_params]
      end

      def security_and_privacy_statement_permitted_params
        %i[title description]
      end

      def technical_resource_permitted_params
        %i[description] + [identifier: identifier_permitted_params]
      end

      def distribution_permitted_params
        %i[title description format byte_size access_url download_url
           data_access available_until] +
          [licenses: license_permitted_params, host: host_permitted_params]
      end

      def license_permitted_params
        %i[license_ref start_date]
      end

      def host_permitted_params
        %i[title description supports_versioning backup_type backup_frequency
           storage_type availability geo_location certified_with pid_system] +
          [host_ids: identifier_permitted_params]
      end
    end
  end
end
