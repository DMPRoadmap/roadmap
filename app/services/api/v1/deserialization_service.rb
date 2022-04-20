# frozen_string_literal: true

module Api
<<<<<<< HEAD

  module V1

    class DeserializationService

      class << self

=======
  module V1
    # Generic deserialization helper methods
    class DeserializationService
      class << self
>>>>>>> upstream/master
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
<<<<<<< HEAD
=======
        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
>>>>>>> upstream/master
        def attach_identifier(object:, json:)
          return object unless object.present? && object.respond_to?(:identifiers) &&
                               json.present? &&
                               json[:type].present? && json[:identifier].present?

          existing = object.identifiers.select do |id|
            id.identifier_scheme&.name&.downcase == json[:type].downcase
          end
          return object if existing.present?

          object.identifiers << Api::V1::Deserialization::Identifier.deserialize(
            class_name: object.class.name, json: json
          )
          object
        end
<<<<<<< HEAD
=======
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
>>>>>>> upstream/master

        # Translates the role in the json to a Contributor role
        def translate_role(role:)
          default = ::Contributor.default_role
          return default unless role.present?

          role = role.to_s unless role.is_a?(String)

          # Strip off the URL if present
          url = ::Contributor::ONTOLOGY_BASE_URL
<<<<<<< HEAD
          role = role.gsub("#{url}/", "").downcase if role.include?(url)
=======
          role = role.gsub("#{url}/", '').downcase if role.include?(url)
>>>>>>> upstream/master

          # Return the role if its a valid one otherwise defualt
          return role if ::Contributor.new.all_roles.include?(role.downcase.to_sym)

          default
        end

        # Retrieve any JSON schema extensions for this application
        def app_extensions(json: {})
<<<<<<< HEAD

          return {} unless json.present? && json[:extension].present?

          app = I18n.with_locale I18n.default_locale do
            ::ApplicationService.application_name
          end
          ext = json[:extension].select { |item| item[app.to_sym].present? }
          ext.first.present? ? ext.first[app.to_sym] : {}
=======
          return {} unless json.present? && json[:extension].present?

          # Note the symbol of the dmproadmap json object
          # nested in extensions which is the container for the json template object, etc.
          ext = json[:extension].select { |item| item[:dmproadmap].present? }
          ext.first.present? ? ext.first[:dmproadmap] : {}
>>>>>>> upstream/master
        end

        # Determines whether or not the value is a DOI/ARK
        def doi?(value:)
          return false unless value.present?

          # The format must match a DOI or ARK and a DOI IdentifierScheme
          # must also be present!
          identifier = ::Identifier.new(value: value)
<<<<<<< HEAD
          scheme = ::IdentifierScheme.find_by(name: "doi")
=======
          scheme = ::IdentifierScheme.find_by(name: 'doi')
>>>>>>> upstream/master
          %w[ark doi].include?(identifier.identifier_format) && scheme.present?
        end

        # Converts the string into a UTC Time string
        def safe_date(value:)
          return nil unless value.is_a?(String)

          Time.parse(value).utc
        rescue ArgumentError
          value.to_s
        end
<<<<<<< HEAD

      end

    end

  end

=======
      end
    end
  end
>>>>>>> upstream/master
end
