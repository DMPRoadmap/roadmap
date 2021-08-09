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
          def deserialize(class_name:, json: {})
            return nil unless class_name.present? &&
                              Api::V1::JsonValidationService.identifier_valid?(json: json)

            json = json.with_indifferent_access
            scheme = ::IdentifierScheme.by_name(json[:type].downcase).first

            # If the scheme is present then this is a identifier that must be
            # unique (e.g. ROR, ORCID) so try to find it
            identifier = ::Identifier.by_scheme_name(scheme, class_name).first if scheme.present?
            return identifier if identifier.present?

            ::Identifier.new(identifier_scheme: scheme, value: json[:identifier])
          end

        end

      end

    end

  end

end
