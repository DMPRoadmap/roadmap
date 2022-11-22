# frozen_string_literal: true

module ExternalApis
  # This service provides an interface to minting/registering DOIs
  # To enable the feature you will need to:
  #   - Identify a DMP ID minting authority (e.g. Datacite, Crossref, etc.)
  #   - Create an account with them and gain access to their API
  #   - Add a `config/initializers/external_apis/[service_name].rb`. Copy one of the
  #     existing ones as reference.
  #   - Create a new service in this directory that inherits from this class.
  #     Then define use the service's API documentation to build mint/update/delete functions
  #   - Also make sure that the `madmp.enable_dmp_id_registration` is set to true in
  #     config/initializers/_dmproadmap.rb
  class BaseDmpIdService < BaseService
    class << self
      # The API endpoint to call to authenticate and receive an auth token to be used
      # with all subsequent communications
      def auth_path
        nil
      end

      # The API endpoint to call to register the Plan with the service and mint a
      # new DMP ID (aka DOI, ARK, etc)
      def mint_path
        nil
      end

      # The callback_path is the API endpoint to send updates to once the Plan has changed
      # or been versioned. Use the `%{dmp_id}` markup to have the Plan's DOI appended to the path.
      # For example: `update_dmp/%{dmp_id}` would become: `updated_dmp/10.123/1234.ABC`
      def callback_path
        nil
      end

      # The HTTP method to be used when using the callback_path
      def callback_method
        :put
      end

      # The name of the associated ApiClient
      def api_client
        nil
      end

      # Ping the DOI API to determine if it is online
      #
      # @return true/false
      def ping
        return true unless active? && heartbeat_path.present?

        resp = http_get(uri: "#{api_base_url}#{heartbeat_path}")
        resp.is_a?(Net::HTTPSuccess)
      end

      # Implement the authentication for the DOI API
      def auth
        true

        # You should implement any necessary authentication step required by the
        # DOI API
      end

      # Implement the call to retrieve/mint a new DOI
      # rubocop:disable Lint/UnusedMethodArgument
      def mint_dmp_id(plan:)
        SecureRandom.uuid

        # Minted DOIs should be stored as an Identifier. For example:
        #    val = "#{landing_page_url}#{dmp_id}"
        #    Identifier.new(identifiable: plan, value: val)

        # When this service is active and the above identifier is available,
        # the link to the DOI will appear on the Project Details page, in plan
        # exports and will become the `dmp_id` in this system's API responses
      end
      # rubocop:enable Lint/UnusedMethodArgument

      # Implement the call to register an associated ApiClient as a Subscriber to the Plan
      # rubocop:disable Lint/UnusedMethodArgument
      def add_subscription(plan:, dmp_id:)
        true
      end
      # rubocop:enable Lint/UnusedMethodArgument

      # Implement the call to update the DOI
      # rubocop:disable Lint/UnusedMethodArgument
      def update_dmp_id(plan:)
        true
      end
      # rubocop:enable Lint/UnusedMethodArgument

      # Implement the call to delete the DOI
      # rubocop:disable Lint/UnusedMethodArgument
      def delete_dmp_id(plan:)
        true
      end
      # rubocop:enable Lint/UnusedMethodArgument
    end
  end
end
