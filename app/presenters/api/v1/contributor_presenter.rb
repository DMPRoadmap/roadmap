# frozen_string_literal: true

module Api
  module V1
    # Helper class for the API V1 contributors views
    class ContributorPresenter
      class << self
        # Convert the specified role into a CRediT Taxonomy URL
        def role_as_uri(role:)
          return nil unless role.present?
          return 'other' if role.to_s.casecmp('other').zero?

          base = Contributor::ONTOLOGY_BASE_URL
          base = "#{base}/" unless base.end_with?('/')
          "#{base}#{role.to_s.downcase.tr('_', '-')}"
        end

        def contributor_id(identifiers:)
          identifiers.find { |id| id.identifier_scheme.name == 'orcid' }
        end
      end
    end
  end
end
