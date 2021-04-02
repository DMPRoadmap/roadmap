# frozen_string_literal: true

module Api

  module V2

    class BaseApiController < ApplicationController

      include ::Doorkeeper::Helpers::Controller

      respond_to :json

      # Skipping the standard Rails authenticity tokens passed in UI
      skip_before_action :verify_authenticity_token

      # Authorization and Token parsing
      before_action :user_from_token, :client_from_token, :scopes_from_token
      before_action :oauth_authorize!, except: %i[heartbeat]

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
        render "/api/v2/heartbeat", status: :ok
      end

      # GET api/v2/me
      # -------------
      # Used by the Doorkeeper OAuth workflow. Once the caller has been authenticated this route can be
      # called to access info about the Client or the ResourceOwner depending on the context
      def me
        return {} unless doorkeeper_token.present?

        if @resource_owner.present?
          render json: {
            email: @resource_owner.email,
            token: doorkeeper_token.token,
            plan_count: @resource_owner.plans&.select { |plan| plan.complete && !plan.is_test? }&.length || 0
          }
        else
          render json: {
            name: @client.name,
            token: doorkeeper_token.token
          }
        end
      end

      protected

      # Generic handler for sending an error back to the caller
      def render_error(errors:, status: :bad_request)
        @payload = { errors: [errors] }
        render "/api/v2/error", status: status
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

      # Authorize the request based on the context of the token:
      # If the :doorkeeper_token has a :resource_owner then it's an :authorization_code request
      # meaning that its a request for data on behalf of a user; otherwise this is a :client_credentials
      # request meaning that the ApiClient or User has requested data directly (not specific to another User)
      def oauth_authorize!

p "RO:"
p @resource_owner.inspect
p "CLIENT:"
p @client.inspect

        @resource_owner.present? ? grant_exists? : true #doorkeeper_authorize!
      end

      # A request on behalf of a resource owner (aka User) requires an access grant
      def grant_exists?
        return false unless @resource_owner.present?

        grants = @resource_owner.access_grants.select do |grant|
          grant.application_id == @client.id && grant.scopes.include?(@scopes)
        end
        grants.any?
      end

      # Find the User from the Doorkeeper token
      def user_from_token
        @resource_owner = User.includes(:plans, :access_grants)
                              .find_by(id: doorkeeper_token.resource_owner_id) if doorkeeper_token
      end

      # Fetch the ApiClient from the Doorkeeper token
      def client_from_token
        @client = ApiClient.find_by(id: doorkeeper_token.application_id) if doorkeeper_token
      end

      # Fetch the scopes from the Doorkeeper token
      def scopes_from_token
        @scopes = doorkeeper_token.scopes if doorkeeper_token
      end

      # Set the generic application and caller variables used in all responses
      def base_response_content
        @application = ApplicationService.application_name
        @caller = request.remote_ip unless @client.present?
        @caller = @client.is_a?(User) ? @client.name(false) : @client.name if @client.present?
      end

      # Retrieve the requested pagination params or use defaults
      # only allow 100 per page as the max
      def pagination_params
        @page = params.fetch("page", 1).to_i
        @per_page = params.fetch("per_page", 20).to_i
        @per_page = 100 if @per_page > 100
      end

      # Parse the body of the incoming request
      def parse_request
        return false unless request.present? && request.body.present?

        body = request.body.read
        @json = JSON.parse(body).with_indifferent_access
      rescue JSON::ParserError => e
        Rails.logger.error "API V2 - JSON Parser: #{e.message}"
        Rails.logger.error request.body
        render_error(errors: _("Invalid JSON format"), status: :bad_request)
        false
      end

      # Record the timestamp
      def log_access
        return false unless @client.present?

        @client.update(last_access: Time.now) if @client.is_a?(ApiClient)
        @client.update(last_api_access: Time.now) if @client.is_a?(User)
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
