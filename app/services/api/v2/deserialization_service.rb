# frozen_string_literal: true

module Api

  module V2

    class DeserializationService

      class << self

        # Finds the object by the specified identifier
        def object_from_identifier(class_name:, json:)
          return nil unless class_name.present? && json.present? &&
                            json[:type].present? && json[:identifier].present?

          clazz = "::#{class_name.capitalize}".constantize
          return nil unless clazz.respond_to?(:from_identifiers)

          clazz.from_identifiers(
            array: [{ name: json[:type], value: json[:identifier] }]
          )
        rescue NameError
          nil
        end

        # Attach the identifier to the object if it does not already exist
        def attach_identifier(object:, json:)
          return object unless object.present? && object.respond_to?(:identifiers) &&
                               json.present? &&
                               json[:type].present? && json[:identifier].present?

pp json

          existing = object.identifiers.select do |id|
            id.identifier_scheme&.name&.downcase == json[:type].downcase
          end
          return object if existing.present?

p "HERE"

          object.identifiers << Api::V2::Deserialization::Identifier.deserialize(
            class_name: object.class.name, json: json
          )
          object
        end

        # Translates the role in the json to a Contributor role
        def translate_role(role:)
          default = ::Contributor.default_role
          return default unless role.present?

          role = role.to_s unless role.is_a?(String)

          # Strip off the URL if present
          url = ::Contributor::ONTOLOGY_BASE_URL
          role = role.gsub(url, "").downcase if role.include?(url)
          role = role.gsub("-", "_")

          # Return the role if its a valid one otherwise defualt
          return role if ::Contributor.new.all_roles.include?(role.downcase.to_sym)

          default
        end

        # Translates the RDA Common Standard for the funding status
        def translate_funding_status(status:)
          case status
          when "rejected"
            "denied"
          when "granted"
            "funded"
          else
            "planned"
          end
        end

        # Retrieve any JSON schema extensions for this application
        def app_extensions(json: {})
          return {} unless json.present? && json[:extension].present?

          app = ::ApplicationService.application_name.split("-").first.downcase
          ext = json[:extension].select { |item| item[app.to_sym].present? }
          ext.first.present? ? ext.first[app.to_sym] : {}
        end

        # Determines whether or not the value is a DOI/ARK
        def doi?(value:)
          return false unless value.present?

          # The format must match a DOI or ARK and a DOI IdentifierScheme
          # must also be present!
          identifier = ::Identifier.new(value: value)
          scheme = ::IdentifierScheme.find_by(name: DoiService.scheme_name)
          scheme.present? &&
            (identifier.identifier_format.include?("ark") || identifier.identifier_format.include?("doi"))
        end

        # Converts the string into a UTC Time string
        def safe_date(value:)
          return nil unless value.is_a?(String)

          Time.parse(value).utc
        rescue ArgumentError
          value.to_s
        end

      end

    end

  end

end
