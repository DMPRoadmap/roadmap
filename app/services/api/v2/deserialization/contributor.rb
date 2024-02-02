# frozen_string_literal: true

module Api
  module V2
    module Deserialization
      # Deserialization of RDA Common Standard for contributors/contacts to Contributors/Users
      class Contributor
        class << self
          # Convert the incoming JSON into a Contributor
          #   {
          #     "role": [
          #       "http://credit.niso.org/contributor-roles/project-administration"
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
          def deserialize(json: {}, is_contact: false)
            return nil unless Api::V2::JsonValidationService.contributor_valid?(
              json: json, is_contact: is_contact
            )

            json = json.with_indifferent_access

            # Try to find the Contributor or initialize a new one
            id_json = json.fetch(:contributor_id, json.fetch(:contact_id, {}))
            contrib = find_or_initialize(id_json: id_json, json: json)
            return nil if contrib.blank?

            # Attach the Org unless its already defined
            contrib.org = Api::V2::Deserialization::Org.deserialize(json: json[:affiliation])

            # Attach the identifier
            contrib = Api::V2::DeserializationService.attach_identifier(
              object: contrib, json: id_json
            )

            # Assign the roles
            contrib = assign_contact_roles(contributor: contrib) if is_contact
            assign_roles(contributor: contrib, json: json)
          end

          # ===================
          # = PRIVATE METHODS =
          # ===================

          private

          # Each plan's contributors are unique records, so if we found a
          # match we need to dup it, otherwise initialize a new one
          def find_or_initialize(id_json:, json: {})
            return nil if json.blank?

            contrib = Api::V2::DeserializationService.object_from_identifier(
              class_name: 'Contributor', json: id_json
            )
            return duplicate_contributor(contributor: contrib) if contrib.present?

            if json[:mbox].present?
              # Try to find by email
              contrib = ::Contributor.where('LOWER(email) = ?', json[:mbox]&.downcase).last
              return duplicate_contributor(contributor: contrib) if contrib.present?
            end

            ::Contributor.new(name: json[:name], email: json[:mbox])
          end

          def duplicate_contributor(contributor:)
            return nil if contributor.blank?

            contrib = contributor.dup
            contrib.plan = nil
            contrib
          end

          # Assign the default Contact roles
          def assign_contact_roles(contributor:)
            return contributor if contributor.blank?

            contributor.data_curation = true
            contributor
          end

          # Assign the specified roles
          def assign_roles(contributor:, json: {})
            return contributor unless contributor.present? && json.present? && json[:role].present?

            json.fetch(:role, []).each do |url|
              role = Api::V2::DeserializationService.translate_role(role: url)
              contributor.send(:"#{role}=", true) if role.present? &&
                                                     contributor.respond_to?(:"#{role}=")
            end
            contributor
          end
        end
      end
    end
  end
end