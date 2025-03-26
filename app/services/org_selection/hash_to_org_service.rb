# frozen_string_literal: true

require 'text'

module OrgSelection
  # This class provides conversion methods for turning OrgSelection::Search
  # results into Orgs and Identifiers
  # For example:
  # {
  #   ror: "http://ror.org/123",
  #   name: "Foo (foo.org)",
  #   sort_name: "Foo"
  # }
  # becomes:
  # An Org with name = "Foo (foo.org)",
  #             identifier (ROR) = "http://example.org/123"
  #
  class HashToOrgService
    class << self
      def to_org(hash:, allow_create: true)
        return nil unless hash.present?

        # Allow for the hash to have either symbol or string keys
        hash = hash.with_indifferent_access

        # 1st: if id is present - find the Org and then verify names match
        org = lookup_org_by_id(hash: hash)
        return org if org.present?

        # 2nd: Search by the external identifiers (e.g. "ror", "fundref", etc.)
        # and then verify a name match
        org = lookup_org_by_identifiers(hash: hash)
        return org if org.present?

        # 3rd: Search by name and then verify exact_match
        org = lookup_org_by_name(hash: hash)
        return org if org.present?

        # Otherwise: Create an Org if allowed
        allow_create ? initialize_org(hash: hash) : nil
      end

      def to_identifiers(hash:)
        return [] unless hash.present?

        out = []
        # Process each of the identifiers
        hash = hash.with_indifferent_access
        idents = hash.slice(*identifier_keys)
        idents.each do |key, value|
          attrs = hash.slice(*attr_keys(hash: hash))
          attrs = {} unless attrs.present?
          out << Identifier.new(
            identifier_scheme_id: IdentifierScheme.by_name(key).first&.id,
            value: value,
            attrs: attrs
          )
        end
        out
      end

      private

      # Lookup the Org by it's :id and return if the name matches the search
      def lookup_org_by_id(hash:)
        org = Org.where(id: hash[:id]).first if hash[:id].present?
        exact_match?(rec: org, name2: hash[:name]) ? org : nil
      end

      # Lookup the Org by its :identifiers and return if the name matches the search
      def lookup_org_by_identifiers(hash:)
        identifiers = hash.slice(*identifier_keys)
        ids = identifiers.map { |k, v| { name: k, value: v } }
        org = Org.from_identifiers(array: ids) if ids.any?
        exact_match?(rec: org, name2: hash[:name]) ? org : nil
      end

      # Lookup the Org by its :name
      def lookup_org_by_name(hash:)
        clean_name = OrgSelection::SearchService.name_without_alias(name: hash[:name])
        org = Org.search(clean_name).first
        exact_match?(rec: org, name2: hash[:name]) ? org : nil
      end

      # Initialize a new Org from the hash
      def initialize_org(hash:)
        return nil unless hash.present? && hash[:name].present?

        Org.new(
          name: hash[:name],
          links: links_from_hash(name: hash[:name], website: hash[:url]),
          language: language_from_hash(hash: hash),
          target_url: hash[:url],
          institution: true,
          is_other: false,
          abbreviation: abbreviation_from_hash(hash: hash)
        )
      end

      # Convert the name and website into Org.links
      def links_from_hash(name:, website:)
        return { org: [] } unless name.present? && website.present?

        { org: [{ link: website, text: name }] }
      end

      # Converts the Org name over to a unique abbreviation
      def abbreviation_from_hash(hash:)
        return nil unless hash.present?

        return hash[:abbreviation] if hash[:abbreviation].present?

        # Get the first letter of each word if no abbreviiation was provided
        OrgSelection::SearchService.name_without_alias(name: hash[:name])
                                   .split.map(&:first).join.upcase
      end

      # Get the language from the hash or use the default
      def language_from_hash(hash:)
        return Language.default unless hash.present? && hash[:language].present?

        Language.where(abbreviation: hash[:language]).first || Language.default
      end

      def identifier_keys
        IdentifierScheme.for_orgs.pluck(:name)
      end

      def attr_keys(hash:)
        return {} unless hash.present?

        non_attr_keys = identifier_keys + %w[sort_name weight score]
        hash.keys.reject { |k| non_attr_keys.include?(k) }
      end

      def exact_match?(rec:, name2:)
        return false unless rec.present? && name2.present?

        OrgSelection::SearchService.exact_match?(name1: rec.name, name2: name2)
      end
    end
  end
end
