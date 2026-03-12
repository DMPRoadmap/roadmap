# frozen_string_literal: true

module Api
  module V2
    class BaseApiController < ApplicationController # rubocop:todo Style/Documentation
      # skipping the standard rails authenticity tokens passed in the UI
      skip_before_action :verify_authenticity_token

      # call doorkeeper to authorize the request
      before_action :doorkeeper_authorize!, except: %i[heartbeat]
      # get details of server (e.g. DMPonline) and client app
      before_action :base_response_content

      before_action :log_access

      before_action :require_read_scope, except: %i[heartbeat me]
      # controller can respond to json format requests
      respond_to :json

      # set up pages in response
      before_action :pagination_params, except: %i[heartbeat]

      rescue_from StandardError, with: :handle_exception

      # GET /api/v2/heartbeat
      def heartbeat
        render '/api/v2/heartbeat'
      end

      # GET /me.json - recommended for doorkeeper gem
      def me
        render json: @resource_owner.slice(:firstname, :surname, :email).merge(
          organisation: @resource_owner.org.name,
          language: @resource_owner.language&.name
        )
      end

      private

      # define instance variable json and associated getter and setter methods
      attr_accessor :json

      def base_response_content
        @application = ApplicationService.application_name
        @client = doorkeeper_token&.application
        @caller = @client&.name || request.remote_ip
        return unless doorkeeper_token&.resource_owner_id

        @resource_owner = User.find(doorkeeper_token.resource_owner_id)
      end

      def log_access
        if @client.present?
          Rails.logger.info "Client (OAuth) application name: #{@client.name}"
          Rails.logger.info "Client (OAuth) application uid: #{@client.uid}"
        end
        Rails.logger.info "Resource owner id: #{@resource_owner.id}" if @resource_owner
      end

      def handle_exception(exception)
        if exception.is_a?(Pundit::NotAuthorizedError)
          handle_client_not_authorized
        else
          handle_internal_server_error(exception)
        end
      end

      def handle_internal_server_error(exception)
        # log server errors
        Rails.logger.error "Exception message: #{exception.message}"

        # inform client of server error
        message = _('There was a problem in the server.')
        @payload = { message: [message] }
        render '/api/v2/error', status: :internal_server_error
      end

      def handle_client_not_authorized
        message = _('The client is not authorized to perform this action.')
        @payload = { message: [message] }
        render '/api/v2/error', status: :forbidden
      end

      # retrieve the requested pagination params or use defaults
      # only allow 100 per page as the max
      def pagination_params
        max_per_page = Rails.configuration.x.application.api_max_page_size
        @page = params.fetch('page', 1).to_i
        @per_page = params.fetch('per_page', max_per_page).to_i
        @per_page = max_per_page if @per_page > max_per_page
      end

      def paginate_response(results:)
        results = results.page(@page).per(@per_page)
        @total_items = results.total_count
        results
      end

      def require_read_scope
        raise Pundit::NotAuthorizedError unless doorkeeper_token.scopes.include?('read')
      end
    end
  end
end
