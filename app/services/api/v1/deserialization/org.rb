# frozen_string_literal: true

module Api

  module V1

    module Deserialization

      class Org

        class << self

          # Convert the incoming JSON into an Org
          #     {
          #       "name": "University of Somewhere",
          #       "abbreviation": "UofS",
          #       "affiliation_id": {
          #         "type": "ror",
          #         "identifier": "https://ror.org/43y4g4"
          #       }
          #     }
          def deserialize!(json: {})
            return nil unless valid?(json: json)

            json = json.with_indifferent_access

            # Try to find the Org by the identifier
            org = find_by_identifier(json: json)

            # Try to find the Org by name
            org = find_by_name(json: json) unless org.present?

            # Org model requires a language so just use the default for now
            org.language = Language.default
            org.abbreviation = json[:abbreviation] if json[:abbreviation].present?
            org.save
            return nil unless org.valid?

            attach_identifier!(org: org, json: json)
          end

          # ===================
          # = PRIVATE METHODS =
          # ===================

          private

          # The JSON is valid if the Org has a name
          def valid?(json: {})
            json.present? && json[:name].present?
          end

          # Locate the Org by its identifier
          def find_by_identifier(json: {})
            return nil unless json.present? &&
                              (json[:affiliation_id].present? ||
                               json[:funder_id].present?)

            id = json.fetch(:affiliation_id, json.fetch(:funder_id, {}))
            ::Org.from_identifiers(
              array: [{ name: id[:type], value: id[:identifier] }]
            )
          end

          # Search for an Org locally and then externally if not found
          # rubocop:disable Metrics/AbcSize
          def find_by_name(json: {})
            return nil unless json.present? && json[:name].present?

            name = json[:name]

            # Search the DB
            org = ::Org.where("LOWER(name) = ?", name.downcase).first
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
          # rubocop:enable Metrics/AbcSize

          # Marshal the Identifier and saves it (unless it exists)
          def attach_identifier!(org:, json: {})
            return org unless json.present?

            hash = json.fetch(:affiliation_id, json.fetch(:funder_id, {}))
            return org unless hash.present?

            Api::V1::Deserialization::Identifier.deserialize!(
              identifiable: org, json: hash
            )
            org.reload
          end

        end

      end

    end

  end

end
