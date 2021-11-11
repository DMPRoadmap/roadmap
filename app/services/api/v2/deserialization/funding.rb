# frozen_string_literal: true

module Api
  module V2
    module Deserialization
      # Deserialization of RDA Common Standard for funding to Plan funder and grant info
      class Funding
        class << self
          # Convert the funding information and attach to the Plan
          #    {
          #      "$ref": "SEE Org.deserialize! for details",
          #      "grant_id": {
          #        "$ref": "SEE Identifier.deserialize for details"
          #      },
          #      "funding_status": "granted"
          #    }
          # rubocop:disable Metrics/AbcSize
          def deserialize(plan:, json: {})
            return nil unless plan.present?
            return plan unless Api::V2::JsonValidationService.funding_valid?(json: json)

            # Attach the Funder
            plan.funder = Api::V2::Deserialization::Org.deserialize(json: json)

            opportunity = json.fetch(:dmproadmap_funding_opportunity_id, {})
            plan.identifier = opportunity[:identifier] if opportunity[:identifier].present?

            plan.funding_status = Api::V2::DeserializationService.translate_funding_status(
              status: json[:funding_status]
            )
            return plan unless json[:grant_id].present?

            # Attach the grant Identifier to the Plan if present
            # Attach the identifier
            plan.grant = Api::V2::Deserialization::Identifier.deserialize(
              class_name: plan.class.name, json: json[:grant_id]
            )
            plan
          end
          # rubocop:enable Metrics/AbcSize
        end
      end
    end
  end
end
