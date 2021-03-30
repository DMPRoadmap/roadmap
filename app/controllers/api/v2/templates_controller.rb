# frozen_string_literal: true

module Api

  module V2

    class TemplatesController < BaseApiController

      # GET /api/v2/templates
      # ---------------------
      def index
        templates = Api::V2::TemplatesPolicy::Scope.new(@client, Template).resolve

        templates = templates.sort { |a, b| a.title <=> b.title }
        @items = paginate_response(results: templates)
        render "/api/v2/templates/index", status: :ok
      end

    end

  end

end
