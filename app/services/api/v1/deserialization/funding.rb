# frozen_string_literal: true

module Api

  module V1

    module Deserialization

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
          def deserialize!(plan:, json: {})
            return nil unless plan.present?
            return plan unless valid?(json: json)

            # Attach the Funder
            plan.funder = Api::V1::Deserialization::Org.deserialize!(json: json)
            return plan unless json[:grant_id].present?
            return nil unless plan.save

            # Attach the grant Identifier to the Plan if present
            deserialize_grant(plan: plan, json: json)
          end

          private

          # The JSON is valid if the Funding has a funder name or funder_id
          # or a grant_id
          def valid?(json: {})
            return false unless json.present?

            funder_id = json.fetch(:funder_id, {})[:identifier]
            grant_id = json.fetch(:grant_id, {})[:identifier]
            json[:name].present? || funder_id.present? || grant_id.present?
          end

          # Convert the JSON grant information into an Identifier
          def deserialize_grant(plan:, json: {})
            return plan unless json.present? && json[:grant_id].present?

            grant = Api::V1::Deserialization::Identifier.deserialize!(
              identifiable: plan, json: json[:grant_id]
            )
            return plan unless grant.present?

            plan.update(grant_id: grant.id)
            plan
          end

        end

      end

    end

  end

end
