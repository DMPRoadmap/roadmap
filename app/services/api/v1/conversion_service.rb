# frozen_string_literal: true

module Api

  module V1

    class ConversionService

      class << self

        # Converts a boolean field to [yes, no, unknown]
        def boolean_to_yes_no_unknown(value)
          return "yes" if [true, 1].include?(value)

          return "no" if [false, 0].include?(value)

          "unknown"
        end

        # Converts a [yes, no, unknown] field to boolean (or nil)
        def yes_no_unknown_to_boolean(value)
          return true if value&.downcase == "yes"

          return nil if value.blank? || value&.downcase == "unknown"

          false
        end

        # Converts the context and value into an Identifier with a psuedo
        # IdentifierScheme for display in JSON partials. Which will result in:
        #   { type: 'context', identifier: 'value' }
        def to_identifier(context:, value:)
          return nil unless value.present? && context.present?

          scheme = IdentifierScheme.new(name: context)
          Identifier.new(value: value, identifier_scheme: scheme)
        end

      end

    end

  end

end
