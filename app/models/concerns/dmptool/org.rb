# frozen_string_literal: true

module Dmptool

  module Org

    extend ActiveSupport::Concern

    class_methods do

      def participating
        includes(identifiers: :identifier_scheme).where(managed: true)
      end

      # Returns all Org's with a Shibboleth entityID stored in the Identifiers table
      # This is used on the app/views/shared/_shib_sign_in_form.html.erb partial which
      # is only used if you have `shibboleth.use_filtered_discovery_service` enabled.
      def shibbolized
        org_ids = Identifier.by_scheme_name("shibboleth", "Org").pluck(:identifiable_id)
        where(managed: true, id: org_ids)
      end

      def initialize_from_org_autocomplete(name:)
        return nil unless name.present?

        is_institution = name.downcase.include?("college") ||
                        name.downcase.include?("university")
        org = Org.new(
          name: name,
          contact_email: Rails.configuration.x.organisation.helpdesk_email,
          contact_name: _("%{app_name} helpdesk") % { app_name: ApplicationService.application_name },
          is_other: false,
          managed: false,
          institution: is_institution,
          organisation: !is_institution
        )
        org.abbreviation = org.name_to_abbreviation
        org
      end

      # Class method shortcut to the name_to_abbreviation instance method
      def name_to_abbreviation(name:)
        return "" unless name.present?

        Org.new(name: name).name_to_abbreviation
      end

    end

    included do
      def shibbolized?
        managed? && identifier_for_scheme(scheme: "shibboleth").present?
      end

      # Returns the name of the Org excluding anything in parenthesis. For example:
      #    'Example University (EU)'  ->  'Example University'
      #    'Sample College (sample.edu)'  ->  'Sample College'
      def name_without_alias
        name&.split(" (")&.first&.strip
      end

      # Convert the Org's name into an abbreviation
      def name_to_abbreviation
        stopwords = %w[a of the and]
        name_without_alias.split(" ")
                          .reject { |word| stopwords.include?(word) }
                          .map { |word| word[0].upcase }
                          .join
      end

      # If the org was created and has a fundref/ror id then it was derived from a
      # User's selection of a RegistryOrg in the UI. We need to update the registry_orgs.org_id
      # to establish the relationship
      def connect_to_registry_org
        registry_org = RegistryOrg.find_by("LOWER(name) = ?", self.name.downcase)
        return true unless registry_org.present?

        # Attach the identifiers
        %w[fundref ror].each do |scheme_name|
          value = registry_org.send(:"#{scheme_name}_id")
          next unless value.present?

          scheme = IdentifierScheme.by_name(scheme_name).first
          next unless scheme.present?

          Identifier.find_or_create_by(
            identifier_scheme: scheme, identifiable: self, value: value
          )
        end

        # Update the original RegistryOrg with the new org's association
        registry_org.update(org_id: self.id)
      end

    end

  end

end
