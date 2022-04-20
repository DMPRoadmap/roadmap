# frozen_string_literal: true

module Api
<<<<<<< HEAD

  module V1

    module Deserialization

      class Org

        class << self

=======
  module V1
    module Deserialization
      # Logic to deserialize RDA common standard to a Org object
      class Org
        class << self
>>>>>>> upstream/master
          # Convert the incoming JSON into an Org
          #     {
          #       "name": "University of Somewhere",
          #       "abbreviation": "UofS",
          #       "affiliation_id": {
          #         "type": "ror",
          #         "identifier": "https://ror.org/43y4g4"
          #       }
          #     }
<<<<<<< HEAD
=======
          # rubocop:disable Metrics/AbcSize
>>>>>>> upstream/master
          def deserialize(json: {})
            return nil unless Api::V1::JsonValidationService.org_valid?(json: json)

            json = json.with_indifferent_access

            # Try to find the Org by the identifier
            id_json = json.fetch(:affiliation_id, json.fetch(:funder_id, {}))
            org = Api::V1::DeserializationService.object_from_identifier(
<<<<<<< HEAD
              class_name: "Org", json: id_json
=======
              class_name: 'Org', json: id_json
>>>>>>> upstream/master
            )

            # Try to find the Org by name
            org = find_by_name(json: json) unless org.present?

            # Org model requires a language so just use the default for now
            org.language = Language.default
            org.abbreviation = json[:abbreviation] if json[:abbreviation].present?
            return nil unless org.valid?
            return org unless id_json[:identifier].present?

            # Attach the identifier
            Api::V1::DeserializationService.attach_identifier(object: org, json: id_json)
          end
<<<<<<< HEAD
=======
          # rubocop:enable Metrics/AbcSize
>>>>>>> upstream/master

          # ===================
          # = PRIVATE METHODS =
          # ===================

          private

          # Search for an Org locally and then externally if not found
          def find_by_name(json: {})
            return nil unless json.present? && json[:name].present?

            name = json[:name]

            # Search the DB
<<<<<<< HEAD
            org = ::Org.where("LOWER(name) = ?", name.downcase).first
=======
            org = ::Org.where('LOWER(name) = ?', name.downcase).first
>>>>>>> upstream/master
            return org if org.present?

            # External ROR search
            results = OrgSelection::SearchService.search_externally(
              search_term: name
            )

            # Grab the closest match - only caring about results that 'contain'
            # the name with preference to those that start with the name
            result = results.select { |r| %i[0 1].include?(r[:weight]) }.first

            # If no good result was found just use the specified name
            result ||= { name: name }
            OrgSelection::HashToOrgService.to_org(hash: result)
          end
<<<<<<< HEAD

        end

      end

    end

  end

=======
        end
      end
    end
  end
>>>>>>> upstream/master
end
