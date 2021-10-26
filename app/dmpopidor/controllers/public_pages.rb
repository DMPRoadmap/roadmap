# frozen_string_literal: true

module Dmpopidor

  module Controllers

    module PublicPages

      # GET template_index
      # -----------------------------------------------------
      # Every publised template is displayed in the Templates Public pages
      # the templates are sorted by org name
      # rubocop:disable Metrics/AbcSize
      def template_index
        @templates_query_params = {
          page: paginable_params.fetch(:page, 1),
          search: paginable_params.fetch(:search, ""),
          sort_field: paginable_params.fetch(:sort_field, "templates.title"),
          sort_direction: paginable_params.fetch(:sort_direction, "asc")
        }

        templates = Template.live(Template.families(Org.all.pluck(:id)).pluck(:family_id))
                            .pluck(:id) <<
                    Template.where(is_default: true).unarchived.published.pluck(:id)
        @templates = Template.includes(:org)
                             .where(id: templates.uniq.flatten)
                             .unarchived.published.order("orgs.name asc").page(1)
      end
      # rubocop:enable Metrics/AbcSize

    end

  end

end
