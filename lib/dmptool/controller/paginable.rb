# frozen_string_literal: true

module Dmptool

  module Controller

    module Paginable

      module Orgs

        # /paginable/orgs/public/:page
        def public
          skip_authorization

          ids = Org.where.not("#{Org.funder_condition}").pluck(:id)

          paginable_renderise(
            partial: "public",
            scope: Org.participating.where(id: ids),
            query_params: { sort_field: "orgs.name", sort_direction: :asc }
          )
        end

      end

    end

  end

end
