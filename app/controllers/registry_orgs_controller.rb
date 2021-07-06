# frozen_string_literal: true

class RegistryOrgsController < ApplicationController

  # GET orgs/search
  def search
    term = autocomplete_term
    if term.present? && term.length > 2
      render json: find_by_search_term(
        term: term,
        funder_only: autocomplete_params[:funder_only] == "true",
        non_funder_only: autocomplete_params[:non_funder_only] == "true",
        known_only: autocomplete_params[:known_only] == "true",
        managed_only: autocomplete_params[:managed_only] == "true"
      )
    else
      render json: []
    end
  end

  private

  def autocomplete_params
    params.permit(
      %i[known_only funder_only managed_only non_funder_only context],
      org_autocomplete: %i[name funder_name org_name],
    )
  end

  # Extracts the search term from the various attributes that can be used
  def autocomplete_term
    autocomplete_hash = autocomplete_params.fetch(:org_autocomplete, {})
    autocomplete_hash[:name] || autocomplete_hash[:org_name] || autocomplete_hash[:funder_name]
  end

  # Search the Orgs and RegistryOrgs tables for the term
  def find_by_search_term(term:, **options)
    return [] unless term.present?

    # If the known_only flag was not set use the default setting from the config
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

    # Search the Orgs table first
    org_matches = orgs_search(
      term: term,
      managed_only: options[:managed_only],
      funder_only: options[:funder_only],
      non_funder_only: options[:non_funder_only]
    )

    matches = (registry_matches + org_matches).flatten.compact.uniq
    sort_search_results(results: matches, term: term)
  end

  # Search Orgs
  def orgs_search(term:, **options)
    matches = Org.where.not(id: RegistryOrg.all.pluck(:org_id)).search(term)

    # If we're only allowing for managed Orgs then filter the others out
    matches = matches.where(managed: true) if options.fetch(:managed_only, false)

    # If we're filtering by funder status
    matches = matches.select { |org| org.funder? } if options.fetch(:funder_only, false)
    matches = matches.reject { |org| org.funder? } if options.fetch(:non_funder_only, false)

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

  # Sort the results by their weight (desacending) and then name (ascending)
  def sort_search_results(results:, term:)
    return [] unless results.present? && results.any? && term.present?

    results.map { |result| { weight: weigh(term: term, org: result), name: result.name, org: result } }
           .sort { |a, b| [b[:weight], a[:name]] <=> [a[:weight], b[:name]] }
           .map { |result| result[:org]&.name }
           .flatten.compact.uniq
  end

  # Weighs the result. The greater the weight the closer the match, preferring Orgs already in use
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

end
