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
          def deserialize(json: {})
            return nil unless Api::V1::JsonValidationService.org_valid?(json: json)

            json = json.with_indifferent_access

            # Try to find the Org by the identifier
            id_json = json.fetch(:affiliation_id, json.fetch(:funder_id, {}))
            org = Api::V1::DeserializationService.object_from_identifier(
              class_name: "Org", json: id_json
            )

            # Try to find the Org by name
            org = Api::V1::DeserializationService.name_to_org(name: json[:name])
            return nil unless org.present?

            # Org model requires a language so just use the default for now
            org.language = Language.default
            org.abbreviation = json[:abbreviation] if json[:abbreviation].present?
            return nil unless org.valid?
            return org unless id_json[:identifier].present?

            # Attach the identifier
            Api::V1::DeserializationService.attach_identifier(object: org, json: id_json)
          end

        end

      end

    end

  end

end
