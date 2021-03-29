# frozen_string_literal: true

module Api

  module V1

    # OAuth Testing Controller
    class OauthTestController < ApplicationController

      include ::Doorkeeper::Helpers::Controller

      respond_to :json

      before_action :user_from_token, :client_from_token, :scopes_from_token
      before_action :oauth_authorize!

      # POST api/v1/test
      def test
        render json: (@resource_owner.present? ? { user: @resource_owner.to_json } : { api_client: params.to_json })
      end

      # GET api/v1/me
      def me
        return {} unless doorkeeper_token.present?

        if @resource_owner.present?
          render json: {
            email: @resource_owner.email,
            token: doorkeeper_token.token,
            plan_count: @resource_owner.plans.select { |plan| plan.complete && !plan.is_test? }.length
          }
        else
          render json: {
            name: @client.name,
            token: doorkeeper_token.token
          }
        end
      end

      private

      def oauth_authorize!
        @resource_owner.present? ? grant_exists? : doorkeeper_authorize!
      end

      # A request on behalf of a resource owner requires an access grant
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
    end

  end

end
