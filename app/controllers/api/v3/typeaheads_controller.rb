# frozen_string_literal: true

module Api
  module V3
    # Endpoints for Work in Progress (WIP) DMPs
    class TypeaheadsController < BaseApiController
      MSG_INVALID_SEARCH = 'Search must be at least 3 characters.'

      # GET /api/v3/funders?search={term}
      def funders
        term = typeahead_params[:search]
        render_error(errors: MSG_INVALID_SEARCH, status: :bad_request) and return if term.blank? || term.length < 3

        # Search the RegistryOrg table first because it has the most extensive search (e.g. acronyms,
        # alternate names, URLs, etc.)
        ror_matches = registry_orgs_search(term: term, funder_only: true)

        # Search the Orgs table next for Orgs that are not connected to ROR yet
        local_matches = orgs_search(term: term, funder_only: true)

        # Prepare the results
        matches = (ror_matches + local_matches).flatten.compact.uniq
        @items = process_results(term: term, matches: matches)
        @use_funder_context = true
        render json: render_to_string(template: '/api/v3/typeaheads/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::TypeaheadsController.funders #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # GET /api/v3/orgs?search={term}
      def orgs
        term = typeahead_params[:search]
        render_error(errors: MSG_INVALID_SEARCH, status: :bad_request) and return if term.blank? || term.length < 3

        # Search the RegistryOrg table first because it has the most extensive search (e.g. acronyms,
        # alternate names, URLs, etc.)
        ror_matches = registry_orgs_search(term: term)

        # Search the Orgs table next for Orgs that are not connected to ROR yet
        local_matches = orgs_search(term: term)

        # Prepare the results
        matches = (ror_matches + local_matches).flatten.compact.uniq
        @items = process_results(term: term, matches: matches)
        render json: render_to_string(template: '/api/v3/typeaheads/index'), status: :ok
      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::TypeaheadsController.orgs #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      # GET /api/v3/repositories?search={term}
      def repositories

      rescue StandardError => e
        Rails.logger.error "Failure in Api::V3::TypeaheadsController.repositories #{e.message}"
        render_error(errors: MSG_SERVER_ERROR, status: 500)
      end

      private

      def typeahead_params
        params.permit(:search, :page, :per_page)
      end

      # Search RegistryOrgs
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def registry_orgs_search(term:, funder_only: false)
        matches = RegistryOrg.includes(org: :users).search(term)

        # If we're filtering by funder status
        return matches.where.not(fundref_id: nil) if funder_only

        matches
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # rubocop:disable Metrics/CyclomaticComplexity
      def orgs_search(term:, funder_only: false)
        known_rors = RegistryOrg.where.not(org_id: nil).pluck(:org_id)
        matches = Org.includes(:users).where.not(id: known_rors).search(term)

        # If we're filtering by funder status
        return matches.select(&:funder?) if funder_only

        matches
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      def process_results(term:, matches: [])
        results = deduplicate(term: term, list: matches)
        results.map(&:name).flatten.compact.uniq

        paginate_response(results: results)
      end

      # Weighs the result. The greater the weight the closer the match, preferring Orgs already in use
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def weigh(term:, org:)
        score = 0
        return score unless term.present? && (org.is_a?(Org) || org.is_a?(RegistryOrg))

        acronym_match = org.acronyms.include?(term.upcase) if org.is_a?(RegistryOrg)
        acronym_match = org.abbreviation&.upcase == term.upcase if org.is_a?(Org)
        starts_with = org.name.downcase.start_with?(term.downcase)

        # Scoring rules explained:
        # 1 - Acronym match
        # 2 - RegistryOrg.starts with term
        # 1 - RegistryOrg.org_id is not nil (if it's a RegistryOrg)
        # 1 - :name includes term
        score += 1 if acronym_match
        score += 2 if starts_with
        score += 1 if org.is_a?(RegistryOrg) && org.org_id.present?
        score += 1 if org.name.downcase.include?(term.downcase) && !starts_with

        score
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # Removes duplicate entries (preferring the one with the most associated Users)
      # For example. if there are 'UNESP' w/4 users, 'unesp' w/12 users and ' unesp' w/1 user in
      # the results, it will use 'unesp'
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def deduplicate(term:, list: [])
        return list unless list.is_a?(Array) && list.any? && term.present?

        # Fetch the user counts so we can sort appropriately
        hashes = list.map do |item|
          {
            normalized: item.name.downcase.strip,
            user_count: item.respond_to?(:users) ? item.users.count : 0,
            weight: weigh(term: term, org: item),
            original: item
          }
        end
        # Sort by the number of users desc, weight desc and then name asc
        hashes = hashes.sort do |a, b|
          [b[:user_count], b[:weight], a[:name]] <=> [a[:user_count], a[:weight], b[:name]]
        end

        # If there are no duplicate names just return the current list
        names = hashes.pluck(:normalized)
        has_duplicates = names.detect { |name| names.count(name) > 1 }.present?
        return hashes.pluck(:original) unless has_duplicates

        out = {}
        hashes.each do |item|
          out[item[:normalized].to_s] = item[:original] if out[item[:normalized].to_s].blank?
        end
        out.values
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    end
  end
end
