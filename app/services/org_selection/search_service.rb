# frozen_string_literal: true

require "text"

module OrgSelection

  # This class provides a search mechanism for Orgs that looks at records in the
  # the database along with any available external APIs
  class SearchService

    class << self

      # Search for organizations both locally and externally
      def search_combined(search_term:)
        return [] unless search_term.present? && search_term.length > 2

        orgs = local_search(search_term: search_term)
        orgs = [] unless orgs.present?
        # If we got an exact match out of the database then skip the
        # external searches
        matches = orgs.select do |org|
          exact_match?(name1: org[:name], name2: search_term)
        end
        return orgs if matches.any?

        externals = externals_search(search_term: search_term)
        externals = [] unless externals.present?
        prepare(search_term: search_term, records: orgs + externals)
      end

      # Search for organizations via External APIs
      def search_externally(search_term:)
        return [] unless search_term.present? && search_term.length > 2

        orgs = externals_search(search_term: search_term)
        prepare(search_term: search_term, records: orgs)
      end

      # Search for organizations in the local DB only
      def search_locally(search_term:)
        return [] unless search_term.present? && search_term.length > 2

        orgs = local_search(search_term: search_term)
        prepare(search_term: search_term, records: orgs)
      end

      # Determines whether or not the 2 names match (ignoring parenthesis text)
      def exact_match?(name1:, name2:)
        return false unless name1.present? && name2.present?

        a = name_without_alias(name: name1.downcase)
        b = name_without_alias(name: name2.downcase)
        a == b
      end

      # Removes the parenthesis portion of the name. For example:
      #   "Foo College (foo.edu)" --> "Foo College"
      def name_without_alias(name:)
        return "" unless name.present?

        name.split(" (")&.first&.strip
      end

      private

      def local_search(search_term:)
        return [] unless search_term.present?

        Rails.cache.fetch(["org_selection-local", search_term], expires_in: 1.day) do
          Org.includes(identifiers: :identifier_scheme)
             .search(name_without_alias(name: search_term)).to_a
        end
      end

      def externals_search(search_term:)
        return [] unless ExternalApis::RorService.active? && search_term.present?

        Rails.cache.fetch(["org_selection-ror", search_term], expires_in: 1.day) do
          ExternalApis::RorService.search(term: search_term)
        end
      end

      # Prepares all of the records for the view. Records that are Org models get
      # converted over to a hash, all other records (e.g. from the ROR API) are
      # expected to already be in the appropriate hash format.
      def prepare(search_term:, records:)
        return [] unless search_term.present? && records.present? && records.is_a?(Array)

        array = []
        records.map do |rec|
          item = rec.is_a?(Org) ? OrgSelection::OrgToHashService.to_hash(org: rec) : rec
          array << evaluate(search_term: search_term, record: item)
        end
        sort(array: deduplicate(records: filter(array: array)))
      end

      # Removes any duplicates by comparing the sort names and ids
      def deduplicate(records:)
        return [] unless records.present? && records.is_a?(Array)

        out = []
        found = []
        records.each do |rec|
          next if found.include?(rec[:sort_name]) || found.include?(rec[:id])

          found << rec[:sort_name]
          found << rec[:id] if rec[:id].present?
          out << rec
        end
        out
      end

      # Resorts the results returned from ROR so that any exact matches
      # appear at the top of the list. For example a search for `Example`:
      #     - Example College
      #     - Example University
      #     - University of Example
      #     - Universidade de Examplar
      #     - Another College that ROR has a matching alias for
      #
      def sort(array:)
        return [] unless array.present? && array.is_a?(Array)

        # Sort the results by score + weight + name
        array.sort do |a, b|
          # left = [a[:weight], a[:score], a[:sort_name]]
          # right = [b[:weight], b[:score], b[:sort_name]]
          [a[:weight], a[:sort_name]] <=> [b[:weight], b[:sort_name]]
        end
      end

      # Score and weigh the record
      def evaluate(search_term:, record:)
        return record unless record.present? && search_term.present?

        # Score and weigh each of the record
        scr = score(search_term: search_term, item_name: record[:name])
        wght = weigh(search_term: search_term, item_name: record[:name])
        record.merge(score: scr, weight: wght)
      end

      # Call the base service's compare_strings
      def score(search_term:, item_name:)
        return 99 unless search_term.present? && item_name.present?

        Text::Levenshtein.distance(search_term.downcase, item_name.downcase)
      end

      # Weighs the result. The lower the weight the closer the match
      def weigh(search_term:, item_name:)
        return 3 unless search_term.present? && item_name.present?

        return 0 if item_name.downcase.start_with?(search_term.downcase)

        return 1 if item_name.downcase.include?(search_term.downcase)

        2
      end

      # Discard any results that are not valid matches
      def filter(array:)
        return [] unless array.present? && array.is_a?(Array)

        array.select do |hash|
          # If the natural language processing score is <= 25 OR the
          # weight is less than 1 (starts with or includes the search term)
          hash.fetch(:score, 0) <= 25 || hash.fetch(:weight, 1) < 2
        end
      end

    end

  end

end
