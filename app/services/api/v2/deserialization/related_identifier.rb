# frozen_string_literal: true

module Api

  module V2

    module Deserialization

      class RelatedIdentifier

        class << self

          # Convert the incoming JSON into an Identifier
          #    {
          #      "descriptor": "is_referenced_by",
          #      "type": "url",
          #      "identifier": "https://example.org/12345"
          #    }
          def deserialize(plan:, json: {})
            return nil unless plan.present? &&
                              Api::V2::JsonValidationService.related_identifier_valid?(
                                json: json
                              )

            json = json.with_indifferent_access
            r_id = ::RelatedIdentifier.find_or_initialize_by(identifiable: plan,
                                                             value: json[:identifier])

            relation_type = json[:descriptor]
            # Note that the 'references' value is changed to 'does_reference' in this list
            # because 'references' conflicts with an ActiveRecord method
            relation_type = "does_reference" if relation_type == "references"

            work_type = json[:work_type].downcase if valid_work_type?(json: json)
            r_id.relation_type = relation_type
            r_id.work_type = json[:work_type] if work_type
            r_id.identifier_type = json[:type].underscore
            r_id
          end

          private

          def valid_work_type?(json:)
            return false unless json.present? && json[:work_type].present?

            ::RelatedIdentifier.work_types.keys.include?(json[:work_type].downcase)
          end

        end

      end

    end

  end

end
