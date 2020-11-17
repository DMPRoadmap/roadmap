# frozen_string_literal: true

module Api

  module V1

    class TemplatesController < BaseApiController

      respond_to :json

      # GET /api/v1/templates
      def index
        # If this is a User and not an ApiClient include the Org's
        # templates and customizations as well as the public ones
        if client.is_a?(User)
          # TODO: there are much cleaner - Railsish ways to do this in Rails 5+
          #       combining the 2 (Public and Organizational) after the queries
          #       converts templates to an Array which is incompatible with
          #       Kaminari's pagination
          where_clause = <<-SQL
            (visibility = 0 AND org_id = ?) OR
            (visibility = 1 AND customization_of IS NULL)
          SQL
          templates = Template.includes(org: :identifiers).joins(:org)
                              .published
                              .where(where_clause, client.org&.id)
                              .order(:title)
        else
          templates = Template.includes(org: :identifiers).joins(:org)
                              .published
                              .publicly_visible
                              .where(customization_of: nil)
                              .order(:title)
        end

        templates = templates.order(:title)
        @items = paginate_response(results: templates)
        render "/api/v1/templates/index", status: :ok
      end
      # rubocop:enable

    end

  end

end
