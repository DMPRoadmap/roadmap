# frozen_string_literal: true

module Api
  module V2
    # provides a list of templates for API V2
    class TemplatesController < BaseApiController
      respond_to :json

      # GET /api/v2/templates
      def index
        templates = Api::V2::TemplatesPolicy::Scope.new(@resource_owner).resolve
        @items = paginate_response(results: templates)
        render '/api/v2/templates/index', status: :ok
      end
    end
  end
end
