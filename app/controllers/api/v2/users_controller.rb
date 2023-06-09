# frozen_string_literal: true

module Api
  module V2
    # Endpoints for Template interactions
    class UsersController < BaseApiController
      respond_to :json

      # GET /me
      def me; end
    end
  end
end
