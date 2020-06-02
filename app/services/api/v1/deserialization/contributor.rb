# frozen_string_literal: true

module Api

  module V1

    module Deserialization

      class Contributor

        class << self

          # Convert the incoming JSON into a Contributor
          #   {
          #     "role": [
          #       "https://dictionary.casrai.org/Contributor_Roles/Project_administration"
          #     ],
          #     "name": "Jane Doe",
          #     "mbox": "jane.doe@university.edu",
          #     "affiliation": {
          #       "name": "University of Somewhere",
          #       "abbreviation": "UofS",
          #       "affiliation_id": {
          #         "type": "ror",
          #         "identifier": "https://ror.org/43y4g4"
          #       }
          #     },
          #     "contributor_id": {
          #       "type": "orcid",
          #       "identifier": "0000-0000-0000-0000"
          #     }
          #   }
          def deserialize!(plan_id:, json: {}, is_contact: false)
            return nil unless valid?(is_contact: is_contact, json: json)

            json = json.with_indifferent_access
            contributor = marshal_contributor(plan_id: plan_id,
                                              is_contact: is_contact, json: json)
            contributor.save
            return nil unless contributor.valid?

            attach_identifier!(contributor: contributor, json: json)
          end

          # ===================
          # = PRIVATE METHODS =
          # ===================

          private

          # The JSON is valid if the Contributor has a name or email
          # and roles (if this is not the Contact)
          def valid?(is_contact:, json: {})
            return false unless json.present?
            return false unless json[:name].present? || json[:mbox].present?

            is_contact ? true : json[:role].present?
          end

          # Find or initialize the Contributor
          # rubocop:disable Metrics/CyclomaticComplexity
          def marshal_contributor(plan_id:, is_contact:, json: {})
            return nil unless plan_id.present? && json.present?

            # Try to find the Org by the identifier
            contributor = find_by_identifier(json: json)

            # Search by email if available and not found above
            unless contributor.present?
              contributor = find_or_initialize_by(plan_id: plan_id, json: json)
            end

            # Attach the Org unless its already defined
            contributor.org = deserialize_org(json: json) unless contributor.org.present?

            # Assign the roles
            contributor = assign_contact_roles(contributor: contributor) if is_contact
            assign_roles(contributor: contributor, json: json) unless is_contact

            contributor
          end
          # rubocop:enable Metrics/CyclomaticComplexity

          # Locate the Contributor by its identifier
          def find_by_identifier(json: {})
            return nil unless json.present? &&
                              (json[:contact_id].present? ||
                               json[:contributor_id].present?)

            id = json.fetch(:contact_id, json.fetch(:contributor_id, {}))
            ::Contributor.from_identifiers(
              array: [{ name: id[:type], value: id[:identifier] }]
            )
          end

          # Find the Contributor by its name or email or initialize one
          def find_or_initialize_by(plan_id:, json: {})
            return nil unless json.present? && plan_id.present?

            if json[:mbox].present?
              contributor = ::Contributor.find_by(plan_id: plan_id,
                                                  email: json[:mbox])
              return contributor if contributor.present?
            end
            ::Contributor.find_or_initialize_by(plan_id: plan_id,
                                                name: json[:name],
                                                email: json[:mbox])
          end

          # Call the deserializer method for the Org
          def deserialize_org(json: {})
            return nil unless json.present? && json[:affiliation].present?

            Api::V1::Deserialization::Org.deserialize!(json: json[:affiliation])
          end

          # Assign the default Contact roles
          def assign_contact_roles(contributor:)
            return nil unless contributor.present?

            contributor.data_curation = true
            contributor
          end

          # Assign the specified roles
          def assign_roles(contributor:, json: {})
            return nil unless contributor.present?
            return contributor unless json.present? && json[:role].present?

            json.fetch(:role, []).each do |url|
              role = translate_role(role: url)
              contributor.send(:"#{role}=", true) if role.present?
            end
            contributor
          end

          # Marshal the Identifier and saves it (unless it exists)
          def attach_identifier!(contributor:, json: {})
            return contributor unless json.present?

            hash = json.fetch(:contact_id, json.fetch(:contributor_id, {}))
            return contributor unless hash.present?

            Api::V1::Deserialization::Identifier.deserialize!(
              identifiable: contributor, json: hash
            )
            contributor.reload
          end

          # Translates the role in the json to a PlansContributor role
          def translate_role(role:)
            default = ::Contributor.default_role
            return default unless role.present?

            role = role.to_s unless role.is_a?(String)

            # Strip off the URL if present
            url = ::Contributor::ONTOLOGY_BASE_URL
            role = role.gsub("#{url}/", "").downcase if role.include?(url)

            # Return the role if its a valid one otherwise defualt
            return role if ::Contributor.new.respond_to?(role.downcase.to_sym)

            default
          end

        end

      end

    end

  end

end
