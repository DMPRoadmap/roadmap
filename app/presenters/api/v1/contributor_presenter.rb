# frozen_string_literal: true

module Api
<<<<<<< HEAD

  module V1

    class ContributorPresenter

      class << self

        # Convert the specified role into a CRediT Taxonomy URL
        def role_as_uri(role:)
          return nil unless role.present?
          return "other" if role.to_s.downcase == "other"
=======
  module V1
    # Helper class for the API V1 contributors views
    class ContributorPresenter
      class << self
        # Convert the specified role into a CRediT Taxonomy URL
        def role_as_uri(role:)
          return nil unless role.present?
          return 'other' if role.to_s.downcase == 'other'
>>>>>>> upstream/master

          "#{Contributor::ONTOLOGY_BASE_URL}/#{role.to_s.downcase.gsub('_', '-')}"
        end

        def contributor_id(identifiers:)
<<<<<<< HEAD
          identifiers.select { |id| id.identifier_scheme.name == "orcid" }.first
        end

      end

    end

  end

=======
          identifiers.select { |id| id.identifier_scheme.name == 'orcid' }.first
        end
      end
    end
  end
>>>>>>> upstream/master
end
