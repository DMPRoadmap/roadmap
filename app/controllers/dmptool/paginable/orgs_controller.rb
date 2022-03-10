# frozen_string_literal: true

module Dmptool
  module Paginable
    # Paginable component of our 'Participating Institutions' page
    module OrgsController
      # /paginable/orgs/public/:page
      def public
        skip_authorization
        ids = ::Org.where.not(::Org.funder_condition).pluck(:id)

        paginable_renderise(
          partial: 'public',
          scope: ::Org.participating.where(id: ids),
          query_params: { sort_field: 'orgs.name', sort_direction: :asc },
          format: :json
        )
      end
    end
  end
end
