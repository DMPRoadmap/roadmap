# frozen_string_literal: true

module Api
  module V2
    module Deserialization
      # Deserialization of RDA Common Standard for identifiers to Identifiers
      class Identifier
        class << self
          # Convert the incoming JSON into an Identifier
          #    {
          #      "type": "ror",
          #      "identifier": "https://ror.org/43y4g4"
          #    }
          # rubocop:disable Metrics/AbcSize
          def deserialize(class_name:, json: {})
            return nil unless class_name.present? &&
                              Api::V2::JsonValidationService.identifier_valid?(json: json)

            json = json.with_indifferent_access
            scheme = ::IdentifierScheme.by_name(json[:type].downcase).first

            # If the scheme is present then this is a identifier that must be
            # unique (e.g. ROR, ORCID) so try to find it
            if scheme.present?
              val = json[:identifier] if json[:identifier].start_with?(scheme.identifier_prefix)
              val = "#{scheme.identifier_prefix}#{json[:identifier]}" unless val.present?
              identifier = ::Identifier.by_scheme_name(scheme, class_name).where(value: val).first
              return identifier if identifier.present?
            end

            ::Identifier.new(identifier_scheme: scheme, value: json[:identifier])
          end
          # rubocop:enable Metrics/AbcSize
        end
      end
    end
  end
end
