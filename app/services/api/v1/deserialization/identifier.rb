# frozen_string_literal: true

module Api

  module V1

    module Deserialization

      class Identifier

        class << self

          # Convert the incoming JSON into an Identifier
          #    {
          #      "type": "ror",
          #      "identifier": "https://ror.org/43y4g4"
          #    }
          def deserialize!(identifiable:, json: {})
            return nil unless identifiable.present? && valid?(json: json)

            json = json.with_indifferent_access
            scheme = ::IdentifierScheme.by_name(json[:type].downcase).first
            identifier = identifier_for_scheme(scheme: scheme,
                                               identifiable: identifiable,
                                               json: json)
            return identifier if identifier.present?

            ::Identifier.find_or_create_by(identifier_scheme: scheme,
                                           identifiable: identifiable,
                                           value: json[:identifier])
          end

          # ===================
          # = PRIVATE METHODS =
          # ===================

          private

          # The JSON is valid if both the type and identifier are present
          def valid?(json:)
            json.present? && json[:type].present? && json[:identifier].present?
          end

          # Find or intialize an Identifier
          def identifier_for_scheme(scheme:, identifiable:, json: {})
            return nil unless identifiable.present? &&
                              json.present? &&
                              scheme.present?

            identifier = ::Identifier.find_by(identifier_scheme: scheme,
                                              identifiable: identifiable)
            return nil unless identifier.present?

            identifier.update(value: json[:identifier])
            identifier.reload
          end

        end

      end

    end

  end

end
