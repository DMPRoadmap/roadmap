# frozen_string_literal: true

module Api

  module V1

    class TemplatesController < BaseApiController

      respond_to :json

      # ALL can see published - public templates
      # User can see their published Org templates and cusstomizations
      # GET /api/v1/templates
      def index
        authorize Template
        @items = policy_scope(Template)
        @items = paginate_response(results: @items) if @items.any?
        render "/api/v1/templates/index", status: :ok
      end

    end

  end

end
