# frozen_string_literal: true

require "text"

# rubocop:disable Metrics/BlockLength
namespace :org_cleanup do
  desc "Detect duplicate Orgs"
  task find_dups: :environment do
    org_hashes = Org.all.collect do |org|
      cleansed = OrgSelection::SearchService.name_without_alias(name: org.name).downcase
      {
        id: org.id,
        original: org.name,
        cleansed: cleansed,
        abbreviation: name_to_abbreviation(name: cleansed),
        matches: []
      }
    end

    p "Scanning #{org_hashes.length} Orgs for duplicates ..."
    match_array = org_hashes.map { |o| o[:cleansed] }
    org_hashes.each do |hash|
      # p "Checking '#{hash[:original]}' -- '#{hash[:abbreviation]}'"
      matches = match_array.select do |name|
        next if name == hash[:cleansed]

        abbrev_match = hash[:abbreviation] == name_to_abbreviation(name: name)
        lev_score = Text::Levenshtein.distance(hash[:cleansed], name)
        white_score = Text::WhiteSimilarity.similarity(hash[:cleansed], name)

        (abbrev_match && white_score > 0.8) || (lev_score < 5 && white_score > 0.9)
      end
      # Remove this one if no matches were identified so that we stop checking it
      match_array.delete(hash[:cleansed]) unless matches.any?
      next unless matches.any?

      # Add all of the matching Org ids
      hash[:matches] = matches.collect do |m|
        org_hashes.select { |o| o[:cleansed] == m }.collect { |h| h[:id] }
      end
    end

    found = org_hashes.select { |o| o[:matches].any? }
    p "DONE!"
    p ""
    p "No duplicates detected" unless found.any?

    found.each do |hash|
      p "#{hash[:id]} - '#{hash[:original]}' may match Org(s): #{hash[:matches]}"
    end
  end

  desc "Find ROR and Crossref funder IDs for Orgs"
  task rorify: :environment do
    ror = IdentifierScheme.by_name("ror").first

    if ror.present?
      orgs = Org.includes(identifiers: :identifier_scheme).where(is_other: false).reject do |org|
        # Since the ROR API provides both ROR and Crossref Funder IDs just check for 'ror'
        org.identifier_for_scheme(scheme: ror).present?
      end

      p "This process will only use results from the ROR API that have a close NLP match and"\
        "that contain the name of the org we have in the database!"\
        ""
      orgs.each do |org|
        name = OrgSelection::SearchService.name_without_alias(name: org.name).downcase
        p "Searching ROR for '#{name}'"
        results = fetch_ror_matches(name: name)

        p "    no matches found" unless results.any?
        next unless results.any?

        results = results.sort { |a, b| a[:score] + a[:weight] <=> b[:score] + b[:weight] }
        ids = OrgSelection::HashToOrgService.to_identifiers(hash: results.first)
        ids.each do |id|
          id.identifiable = org
          p "    adding #{id.value}" if id.valid?
          id.save
        end
      end
    else
      p "No IdentifierScheme defined for 'ror'!"
    end
  end

  def name_to_abbreviation(name:)
    return "" unless name.present?

    stopwords = %w[the of]
    words = name.split(" ").reject { |w| stopwords.include?(w.downcase) }
    words.collect { |w| w[0] }.join.upcase
  end

  # Retrieves the matches from the ROR API and filters out only close matches
  def fetch_ror_matches(name:)
    return [] unless name.present?

    OrgSelection::SearchService.search_externally(search_term: name).select do |hash|
      # If the natural language processing score is <= 25 OR the
      # weight is less than 1 (starts with or includes the search term)
      hash.fetch(:score, 0) <= 25 && hash.fetch(:weight, 1) < 2
    end
  end
end
# rubocop:enable Metrics/BlockLength
