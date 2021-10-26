# frozen_string_literal: true

module ExternalApis

  # This service provides an interface to minting/registering DOIs
  # To enable the feature you will need to:
  #   - Identify a DOI minting authority (e.g. Datacite, Crossref, etc.)
  #   - Create an account with them and gain access to their API
  #   - Update the `config/initializers/external_apis/doi.rb`
  #   - Update this service to mint DOIs (based on their API documentation)
  class DoiService < BaseService

    class << self

      # Retrieve the config settings from the initializer
      def landing_page_url
        Rails.configuration.x.doi&.landing_page_url || super
      end

      def api_base_url
        Rails.configuration.x.doi&.api_base_url || super
      end

      def active?
        Rails.configuration.x.doi&.active || super
      end

      def heartbeat_path
        Rails.configuration.x.doi&.heartbeat_path
      end

      def auth_path
        Rails.configuration.x.doi&.auth_path
      end

      def mint_path
        Rails.configuration.x.doi&.mint_path
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
      def mint(plan:)
        SecureRandom.uuid

        # Minted DOIs should be stored as an Identifier. For example:
        #    doi_url = "#{landing_page_url}#{doi}"
        #    Identifier.new(identifiable: plan, value: doi_url)

        # When this service is active and the above identifier is available,
        # the link to the DOI will appear on the Project Details page, in plan
        # exports and will become the `dmp_id` in this system's API responses
      end
      # rubocop:enable Lint/UnusedMethodArgument

    end

  end

end
