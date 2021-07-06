# frozen_string_literal: true

require "text"

class OrgSearchService

  class << self

    def search(term:, **options)
      return [] unless term.present?

      known_only = options.fetch(:known_only, Rails.configuration.x.application.restrict_orgs)

      # Search the RegistryOrg table first because it has the most extensive search (e.g. acronyms,
      # alternate names, URLs, etc.)
      registry_matches = registry_orgs_search(
        term: term,
        known_only: known_only,
        managed_only: options[:managed_only],
        funder_only: options[:funder_only],
        non_funder_only: options[:non_funder_only]
      )

p "In the Registry? #{registry_matches.select { |r| r.name === "Gateshead Health NHS Foundation Trust (qegateshead.nhs.uk)" }.present?}"
pp registry_matches

      # Search the Orgs table first
      org_matches = orgs_search(
        term: term,
        managed_only: options[:managed_only],
        funder_only: options[:funder_only],
        non_funder_only: options[:non_funder_only]
      )

p "In the Orgs? #{org_matches.select { |r| r.name === "Gateshead Health NHS Foundation Trust (qegateshead.nhs.uk)" }.present?}"
pp org_matches


      prep_matches(term: term, org_matches: org_matches, registry_matches: registry_matches)
    end

    private

    # Take all of the search results and then score/weight and sort them
    def prep_matches(term:, org_matches: [], registry_matches: [])
      matches = (registry_matches + org_matches).flatten.compact.uniq
      matches = sort(array: score_and_weight(matches: matches, term: term))
      matches.map { |match| match[:org].name }
    end

    # Search Orgs
    def orgs_search(term:, **options)
      matches = Org.where.not(id: RegistryOrg.all.pluck(:org_id)).search(term)

      # If we're only allowing for managed Orgs then filter the others out
      matches = matches.where(managed: true) if options.fetch(:managed_only, false)

      # If we're filtering by funder status
      matches = matches.funders if options.fetch(:funder_only, false)
      matches = matches.not_funders if options.fetch(:non_funder_only, false)

      matches
    end

    # Search RegistryOrgs
    def registry_orgs_search(term:, **options)
      matches = RegistryOrg.includes(:org).search(term)

      # If we are only allowing known Orgs then filter by org_id presence
      matches = matches.where.not(org_id: nil) if options.fetch(:known_only, false)

      # If we're filtering by funder status
      matches = matches.where.not(fundref_id: nil) if options.fetch(:funder_only, false)
      matches = matches.where(fundref_id: nil) if options.fetch(:non_funder_only, false)

      # If we're only allowing for managed Orgs then filter the others out
      managed_only = options.fetch(:managed_only, false)
      matches = matches.select { |match| match.org.nil? || match.org.managed? } if managed_only

      matches
    end

    def score_and_weight(matches:, term:)
      return [] unless matches.is_a?(Array) && term.present?

      # Return the Org and its weight
      matches.map do |match|
        org = match.is_a?(RegistryOrg) ? match.to_org : match
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
