# frozen_string_literal: true

module Api

  module V2

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
            return nil unless Api::V2::JsonValidationService.org_valid?(json: json)

            json = json.with_indifferent_access

            # Try to find the Org by the identifier
            id_json = json.fetch(:affiliation_id, json.fetch(:funder_id, {}))
            org = Api::V2::DeserializationService.object_from_identifier(
              class_name: "Org", json: id_json
            )
            return org if org.present?

            # Try to find the Org by name
            org = find_by_name(json: json)
            return org if org.present? && !org.new_record?

            # Org model requires a language so just use the default for now
            org.language = Language.default
            org.abbreviation = json[:abbreviation] if json[:abbreviation].present?
            return nil unless org.valid?
            return org unless id_json[:identifier].present?

            # Attach the identifier
            Api::V2::DeserializationService.attach_identifier(object: org, json: id_json)
          end

          # ===================
          # = PRIVATE METHODS =
          # ===================

          private

          # Search for an Org locally and then externally if not found
          def find_by_name(json: {})
            return nil unless json.present? && json[:name].present?

            name = json[:name]

            # Search the DB
            org = ::Org.where("LOWER(name) = ?", name.downcase).first
            return org if org.present?

            # Skip if restrict_orgs is set to true!
            if !Rails.configuration.x.application.restrict_orgs
              # fetch from the ror table
              registry_org = RegistryOrg.where("LOWER(name) = ?", name.downcase).first

              # If managed_only make sure the org is managed!
              return org_from_registry_org(registry_org: registry_org) if registry_org.present?
                (registry_org.nil? || registry_org&.org&.nil? || !registry_org&.org&.managed?)

              # Convert the RegistryOrg to an Org, save it and then update the RegistryOrg if its ok
              org = create_org_from_registry_org!(registry_org: registry_org)
            end
            return org
          end

          # Create a new Org from the RegistryOrg entry
          def org_from_registry_org!(registry_org:)
            return nil unless registry_org.is_a?(RegistryOrg)
            return registry_org.org if registry_org.org_id.present?

            org = registry_org.to_org
            org.save

            # Attach the identifiers
            %w[fundref ror].each do |scheme_name|
              value = registry_org.send(:"#{scheme_name}_id")
              next unless value.present?

              scheme = IdentifierScheme.by_name(scheme_name).first
              next unless scheme.present?

              Identifier.find_or_create_by(identifier_scheme: scheme, identifiable: org, value: value)
            end

            # Update the original RegistryOrg with the new org's association
            registry_org.update(org_id: org.id)
            org.reload
          end

        end

      end

    end

  end

end
