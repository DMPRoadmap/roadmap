# frozen_string_literal: true
class OpenAireServiceController < ApplicationController
    include HTTParty
    require 'uri'
    require 'nokogiri'

      # DOI integration code
      def search_proxy
        # Build the target URL with the provided DOI
        target_url = "#{api_base_url}" + "#{research_outputs_search_path}" + "?doi=#{params[:doi]}"
        # Set up headers for the request
        headers = {
          'Accept': 'application/xml',
          'Authorization': 'Bearer ' + get_access_token
        }

        # Make a request to the OpenAIRE API using HTTParty
        response = HTTParty.get(target_url, headers: headers)

        if response.code.to_s != "200" || response.body.nil?
          render xml: response.code
        elsif response.code.to_s == "200"
          if response.parsed_response['response']['results'] == nil
          else
            render xml: response
          end
        end
      end

      private

      # Retrieve the config settings from the initializer
      def api_base_url
        Rails.configuration.x.open_aire&.api_base_url
      end

      def active?
        Rails.configuration.x.open_aire&.active
      end

      def search_path
        Rails.configuration.x.open_aire&.search_path
      end

      def default_funder
        Rails.configuration.x.open_aire&.default_funder
      end

      def client_id
        Rails.configuration.x.open_aire&.client_id
      end

      def client_secret
        Rails.configuration.x.open_aire&.client_secret
      end

      def grant_type
        Rails.configuration.x.open_aire&.grant_type
      end

      def open_aire_access_token_endpoint
        Rails.configuration.x.open_aire&.open_aire_access_token_endpoint
      end

      def research_outputs_search_path
        Rails.configuration.x.open_aire&.research_outputs_search_path
      end

      #get access token with client ID and secret
      def get_access_token
        headers = {
          'Content-Type': 'application/x-www-form-urlencoded'
        }
        body = {
          'grant_type': grant_type,
          'client_id': client_id,
          'client_secret': client_secret
        }
        response = HTTParty.post(open_aire_access_token_endpoint, headers: headers, body: body)
        response['access_token']
      end

end
