# frozen_string_literal: true

require "text"

module OrgSelection

  # This class provides a search mechanism for Orgs that looks at records in the
  # the database along with any available external APIs
  class SearchService

    class << self

      def search(term:, funder_only: false)
        return [] unless term.present?

        # Search the org_indices table first
        indices_matches = OrgIndex.search(term)
        indices_matches = indices_matches.where.not(fundref_id: nil) if funder_only

        # Also check the orgs table (for Orgs that do not have an association to org_indices table)
        org_matches = Org.where.not(id: OrgIndex.all.pluck(:org_id)).search(term)
        org_matches = org_matches.funders if funder_only

        matches = sort(array: score_and_weight(matches: indices_matches + org_matches, term: term))
        matches.map { |match| match[:org] }
      end

      private

      def score_and_weight(matches:, term:)
        return [] unless matches.is_a?(Array) && term.present?

        # Return the Org and its weight
        matches.map do |match|
          org = match.is_a?(OrgIndex) ? match.to_org : match
          # Add weight to matches that are not already Org records or that have 1 or fewer users!
          score = weigh(term: term, match: org)
          score += 1 if org.new_record?

          { name: match.name, org: org, weight: score }
        end
      end

      # Weighs the result. The lower the weight the closer the match
      def weigh(term:, match:)
        return 4 unless term.present? && match.present?

        return 0 if match.abbreviation == term.upcase

        return 1 if match.name.downcase.start_with?(term.downcase)

        return 2 if match.name.downcase.include?(term.downcase)

        3
      end

      def sort(array:)
        return [] unless array.is_a?(Array)

        array.sort do |a, b|
          [a[:weight], a[:name]] <=> [b[:weight], b[:name]]
        end
      end

    end

  end

end
