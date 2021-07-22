# frozen_string_literal: true

module Api

  module V1

    class ContributorPresenter

      class << self

        # Convert the specified role into a CRediT Taxonomy URL
        def role_as_uri(role:)
          return nil unless role.present?

          "#{Contributor::ONTOLOGY_BASE_URL}/#{role.to_s.downcase.gsub('_', '-')}"
        end

        def contributor_id(identifiers:)
          identifiers.select { |id| id.identifier_scheme.name == "orcid" }.first
        end

      end

    end

  end

end
