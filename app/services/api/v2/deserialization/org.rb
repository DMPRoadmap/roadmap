# frozen_string_literal: true

module Api
  module V2
    module Deserialization
      # Deserialization of RDA Common Standard for affiliations to Orgs
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
          # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def deserialize(json: {})
            return nil unless Api::V2::JsonValidationService.org_valid?(json: json)

            json = json.with_indifferent_access

            # Try to find the Org by the identifier
            id_json = json.fetch(:affiliation_id, json.fetch(:funder_id, {}))
            org = Api::V2::DeserializationService.object_from_identifier(
              class_name: 'Org', json: id_json
            )
            return org if org.present?

            # Try to find the Org by name
            org = find_by_name(json: json)
            return org if org.present? && !org.new_record?
            return nil unless org.present?

            # Org model requires a language so just use the default for now
            org.language = ::Language.default
            org.abbreviation = json[:abbreviation] if json[:abbreviation].present?
            return nil unless org.valid?
            return org unless id_json[:identifier].present?

            # Attach the identifier
            Api::V2::DeserializationService.attach_identifier(object: org, json: id_json)
          end
          # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

          # ===================
          # = PRIVATE METHODS =
          # ===================

          private

          # Search for an Org locally and then externally if not found
          # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def find_by_name(json: {})
            return nil unless json.present? && json[:name].present?

            name = json[:name]
            # If the name includes context (e.g. '(UCOP)' or '(example.edu)') then do an exact match
            # otherwise strip off any context from the names in the DB when comparing
            #
            # Postgres and MySQL handle index_of differently, so check the DB type
            postgres = ::ApplicationRecord.postgres_db?
            where = 'name' if name.include?('(')
            where = 'SUBSTRING(name, 1, STRPOS(name, \'(\'))' if postgres && where.nil?
            where = 'SUBSTRING_INDEX(name,\'(\',1)' unless where.present?
            where = "LOWER(#{where}) = ?"

            # Search the DB
            org = ::Org.where(where, name.downcase.strip).first unless org.present?
            return org if org.present?

            # Skip if restrict_orgs is set to true!
            unless Rails.configuration.x.application.restrict_orgs
              # fetch from the ror table
              registry_org = ::RegistryOrg.where(where, name.downcase.strip).first

              # If managed_only make sure the org is managed!
              org = org_from_registry_org!(registry_org: registry_org) if registry_org.present?
            end
            org
          end
          # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

          # Create a new Org from the RegistryOrg entry
          # rubocop:disable Metrics/AbcSize
          def org_from_registry_org!(registry_org:)
            return nil unless registry_org.is_a?(::RegistryOrg)
            return registry_org.org if registry_org.org_id.present?

            org = registry_org.to_org
            return nil unless org.present?

            org.save

            # Attach the identifiers
            %w[fundref ror].each do |scheme_name|
              value = registry_org.send(:"#{scheme_name}_id")
              next unless value.present?

              scheme = ::IdentifierScheme.by_name(scheme_name).first
              next unless scheme.present?

              ::Identifier.find_or_create_by(identifier_scheme: scheme, identifiable: org, value: value)
            end

            # Update the original RegistryOrg with the new org's association
            registry_org.update(org_id: org.id)
            org.reload
          end
          # rubocop:enable Metrics/AbcSize
        end
      end
    end
  end
end
