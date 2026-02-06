# frozen_string_literal: true

module Api
  module V2
    # Controller for managing the current user's internal V2 API access token.
    # Provides token rotation for authenticated internal users.
    # See Api::V2::InternalUserAccessTokenService for token implementation details.
    class InternalUserAccessTokensController < ApplicationController
      # POST "/api/v2/internal_user_access_token"
      def create
        authorize current_user, :internal_user_v2_access_token?
        @token = Api::V2::InternalUserAccessTokenService.rotate!(current_user)
        @success = true
        respond_to do |format|
          format.js { render 'users/refresh_token' }
        end
      end
    end
  end
end
