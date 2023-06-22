# frozen_string_literal: true

require 'text'

namespace :org_cleanup do
  desc 'Merge the first org_id into the second org_id'
  task :merge_orgs, %i[loser winner commit] => [:environment] do |_t, args|
    commit_it = args[:commit].to_s == 'true'
    if args[:loser].present? && args[:winner].present?
      loser = Org.includes(:templates, :tracker, :annotations,
                           :departments, :token_permission_types, :funded_plans,
                           identifiers: [:identifier_scheme],
                           guidance_groups: [guidances: [:themes]],
                           users: [identifiers: [:identifier_scheme]])
                 .find_by(id: args[:loser])

      winner = Org.includes(:templates, :tracker, :annotations,
                            :departments, :token_permission_types, :funded_plans,
                            identifiers: [:identifier_scheme],
                            guidance_groups: [guidances: [:themes]],
                            users: [identifiers: [:identifier_scheme]])
                  .find_by(id: args[:winner])

      if loser.present? && winner.present?
        p 'Analyizing merge ... '
        p "    Org that will go away - id: #{loser.id}, name: #{loser.name}"
        p "        annotations that will be moved: #{loser.annotations&.length || 0}"
        p "        departments that will be moved: #{loser.departments&.length || 0}"
        p "        funded plans that will be moved: #{loser.funded_plans&.length || 0}"
        p "        identifiers that will be moved: #{loser.identifiers&.length || 0}"
        p "        guidance_groups that will be moved: #{loser.identifiers&.length || 0}"
        p "        templates that will be moved: #{loser.templates&.length || 0}"
        p "        tracker codes that will be moved: #{loser.tracker.present? ? 1 : 0}"
        p "        users that will be moved: #{loser.users&.length || 0}"

        p "   Org that will remain - id: #{winner.id}, name: #{winner.name}"
        p ''

        if commit_it
          # rubocop:disable Metrics/BlockNesting
          if winner.merge!(to_be_merged: loser)
            p 'Merge complete'
          else
            # rubocop:disable Layout/LineLength
            p 'Something went wrong during thr merge. All changes have been rolled back. Check the logs for more details.'
            # rubocop:enable Layout/LineLength
          end
          # rubocop:enable Metrics/BlockNesting
        else
          p "To commit these changes, please run `rails 'org_cleanup:merge_orgs[#{loser.id},#{winner.id},true]"
        end
      else
        p 'Unable to merge orgs!'
        p 'Unable to find org to merge (the one that will go away)' if loser.blank?
        p 'Unable to find org to merge to (the one that will remain)' if winner.blank?
      end
    else
      p 'Unable to merge orgs!'
      # rubocop:disable Layout/LineLength
      p 'Expected 2 org ids. The 1st representing the Org that will be merged (go away) and the 2nd being the Org that will remain.'
      # rubocop:enable Layout/LineLength
      p 'For example: rails "org_cleanup:merge_orgs[1,2,false]"'
    end
  end

  desc 'Detect duplicate Orgs (RegistryOrg prioritization)'
  task detect_dups: :environment do
    registry_orgs = RegistryOrg.all.map do |registry_org|
      name_parts = registry_org.name.split('(')
      {
        id: registry_org.id,
        org_id: registry_org.org_id,
        ror: registry_org.ror_id,
        fundref: registry_org.fundref_id,
        name: registry_org.name,
        cleansed: remove_stop_words(name: name_parts.first.strip.downcase),
        domain: name_parts.length > 1 ? name_parts.last.delete(')') : nil,
        homepage: registry_org.home_page,
        acronyms: registry_org.acronyms,
        aliases: registry_org.aliases.map { |name| remove_stop_words(name: name) },
        possible_matches: [],
        summary: []
      }
    end

    orgs = Org.includes(:plans, :users, :contributors).all.map do |org|
      name_parts = org.name.split('(')
      {
        id: org.id,
        name: org.name,
        cleansed: remove_stop_words(name: name_parts.first.strip.downcase),
        extra: name_parts.length > 1 ? name_parts.last.delete(')') : nil,
        domain: org.managed? && org.contact_email.present? ? org.contact_email.split('@').last : nil,
        homepage: org.target_url,
        abbreviation: org.abbreviation,
        plan_count: org.plans.length,
        user_count: org.users.length,
        contributor_count: org.contributors.length,
        managed: org.managed?,
        score: 0
      }
    end

    # Go through each RegitryOrg and compare it to the Orgs to find possible duplicates
    registry_orgs = registry_orgs.map do |registry_org|
      # Score all of the Orgs
      scored = orgs.map { |org| weight_and_score(registry_org: registry_org, org: org.dup) }
      next unless scored.any?

      matches = scored.select { |org| org[:score] > 1 }.sort { |a, b| b[:score] <=> a[:score] }
      registry_org[:possible_matches] = matches.flatten.uniq
      registry_org
    end

    # Only keep RegistryOrgs that had Org mataches and have more matches than the Org they
    # are already associated with
    results = registry_orgs.select { |registry_org| registry_org[:possible_matches].any? }
    results = results.reject do |registry_org|
      matches = registry_org[:possible_matches]
      matches.length == 1 && matches.first[:id] == registry_org[:org_id]
    end

    # Only keep RegistryOrgs where one of the possible Org matches is managed
    results = results.select do |registry_org|
      registry_org[:possible_matches].any? { |org| org[:managed] }
    end

    # Go through the remaining Orgs and indicate how they should be handled
    results = results.map do |registry_org|
      if registry_org[:org_id].present?
        registry_org[:possible_matches].each do |org|
          next if org[:id] == registry_org[:org_id]

          org[:recommendation] = "Merge this Org into: #{registry_org[:org_id]}"
          associated = Org.find_by(id: registry_org[:org_id])
          registry_org[:summary] << "Merge (#{org[:id]}) '#{org[:name]}' into (#{associated.id}) '#{associated.name}'"
        end
      elsif registry_org[:possible_matches].length > 1
        winner = registry_org[:possible_matches].first
        registry_org[:possible_matches].each do |org|
          if org == winner
            org[:recommendation] = "Associate this Org to RegistryOrg #{registry_org[:id]}"
            # rubocop:disable Layout/LineLength
            registry_org[:summary] << "Associate (#{org[:id]}) '#{org[:name]}' with RegistryOrg (#{registry_org[:id]}) '#{registry_org[:name]}'"
            # rubocop:enable Layout/LineLength
          else
            org[:recommendation] = "Merge this Org into: #{registry_org[:org_id]}"
            registry_org[:summary] << "Merge (#{org[:id]}) '#{org[:name]}' into (#{winner[:id]}) '#{winner[:name]}'"
          end
        end
      else
        org = registry_org[:possible_matches].first
        org[:recommendation] = "Associate this Org to RegistryOrg #{registry_org[:id]}"
        # rubocop:disable Layout/LineLength
        registry_org[:summary] << "Associate (#{org[:id]}) '#{org[:name]}' with RegistryOrg (#{registry_org[:id]}) '#{registry_org[:name]}'"
        # rubocop:enable Layout/LineLength
      end
      registry_org
    end

    p 'RESULTS:'
    p '----------------------------------------------------'
    p results.length
    pp results

    # Produce a summary for manual intervention
    summarization = results.map do |result|
      next unless result.fetch(:summary, []).any?

      {
        registry_org: { id: result[:id], name: result[:name], ror: result[:ror] },
        actions: result[:summary]
      }
    end

    file = Rails.root.join('tmp', 'detect_duplicates_full.json').open('w')
    file.write(results.to_json)

    summary = Rails.root.join('tmp', 'detect_duplicates_summary.json').open('w')
    summary.write(summarization.to_json)

    p 'Done'
    p 'See tmp/detect_duplicates_full.json for the full analysis'
    p 'See tmp/detect_duplicates_summary.json for a list of manual changes to make'
  end

  # Strip stop words out of the name
  def remove_stop_words(name:)
    return nil if name.blank?

    name = " #{name} ".downcase
    [' de ', ' do ', ' of ', ' the ',
     'college',
     'university', 'universidade', 'universitário'].each do |word|
      name = name.gsub(word.downcase, '')
    end
    name
  end

  # Compare the Org hash to the RegistryOrg hash and score it
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def weight_and_score(registry_org:, org:)
    return org unless registry_org.present? && org.present?

    abbrev_match = registry_org.fetch(:acronyms, []).include?(org[:abbreviation])

    lev_score = Text::Levenshtein.distance(registry_org[:cleansed], org[:cleansed])
    white_score = Text::WhiteSimilarity.similarity(registry_org[:cleansed], org[:cleansed])

    lev_score2 = 0
    white_score2 = 0

    if registry_org.fetch(:aliases, []).any?
      lev_score2 = registry_org[:aliases].sum { |name| Text::Levenshtein.distance(name, org[:cleansed]) }
      white_score2 = registry_org[:aliases].sum { |name| Text::WhiteSimilarity.similarity(name, org[:cleansed]) }
    end

    # If they are already associated, ensure that this is the highest match!
    if org[:id] == registry_org[:org_id]
      org[:score] += 99_999
      org[:recommendation] = "No change. This Org is already associated with #{registry_org[:ror]}"
    end

    # A match on the name beats a match on an alias
    org[:score] += 1 if (abbrev_match && white_score2 > 0.8) || (lev_score2 < 5 && white_score2 > 0.9)
    org[:score] += 2 if (abbrev_match && white_score > 0.8) || (lev_score < 5 && white_score > 0.9)
    return org unless org[:score].positive?

    # Give more weight to a managed org
    org[:score] += 10 if org.fetch(:managed, false)

    # Check form homepage and domain matches
    org[:score] += 50 if registry_org[:domain] == org[:domain]
    org[:score] += 50 if registry_org[:homepage] == org[:homepage]

    # Include the plan and user counts
    org[:score] += org.fetch(:plan_count, 0) +
                   org.fetch(:user_count, 0) +
                   org.fetch(:contributor_count, 0)

    # If the domain extensions do not match then disregard this match
    org[:score] = 0 if org[:domain].present? && (org[:domain].split('.').last != registry_org[:domain].split('.').last)

    org
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  desc 'Detect duplicate Orgs'
  task find_dups: :environment do
    org_hashes = Org.all.collect do |org|
      cleansed = OrgSelection::SearchService.name_without_alias(name: org.name).downcase
      {
        id: org.id,
        original: org.name,
        cleansed: cleansed,
        date: org.created_at.strftime('%Y-%m-%d'),
        abbreviation: name_to_abbreviation(name: cleansed),
        matches: []
      }
    end

    p "Scanning #{org_hashes.length} Orgs for duplicates ..."
    match_array = org_hashes.pluck(:cleansed)
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
        org_hashes.select { |o| o[:cleansed] == m }.pluck(:id)
      end
    end

    found = org_hashes.select { |o| o[:matches].any? }
    p 'DONE!'
    p ''
    p 'No duplicates detected' unless found.any?

    found.each do |hash|
      p "#{hash[:id]} - '#{hash[:original]}' created on #{hash[:date]} may match Org(s): #{hash[:matches]}"
    end
  end

  desc 'Find ROR and Crossref funder IDs for Orgs'
  task rorify: :environment do
    ror = IdentifierScheme.by_name('ror').first

    if ror.present?
      orgs = Org.includes(identifiers: :identifier_scheme).where(is_other: false).reject do |org|
        # Since the ROR API provides both ROR and Crossref Funder IDs just check for 'ror'
        org.identifier_for_scheme(scheme: ror).present?
      end

      p 'This process will only use results from the ROR API that have a close NLP match and' \
        'that contain the name of the org we have in the database!' \
        ''
      orgs.each do |org|
        name = OrgSelection::SearchService.name_without_alias(name: org.name).downcase
        p "Searching ROR for '#{name}'"
        results = fetch_ror_matches(name: name)

        p '    no matches found' unless results.any?
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

  desc "Find Plans with a NULL org_id and populate with the Creator's Org"
  task fix_plans: :environment do
    plans = Plan.includes(roles: { user: :org })
                .joins(roles: { user: :org })
                .where(plans: { org: nil })

    p "Identified #{plans.length} plans with no :org_id"
    plans.each do |plan|
      creator = plan.roles
                    .select(&:creator?)
                    .max(&:created_at)
                    .user
      next unless creator.present? && creator.org.present?

      # Using :update_columns here to prevent the :updated_at from changing
      plan.update_columns(org_id: creator.org.id)
    end
  end

  def name_to_abbreviation(name:)
    return '' if name.blank?

    stopwords = %w[the of]
    words = name.split.reject { |w| stopwords.include?(w.downcase) }
    words.pluck(0).join.upcase
  end

  # Retrieves the matches from the ROR API and filters out only close matches
  def fetch_ror_matches(name:)
    return [] if name.blank?

    OrgSelection::SearchService.search_externally(search_term: name).select do |hash|
      # If the natural language processing score is <= 25 OR the
      # weight is less than 1 (starts with or includes the search term)
      hash.fetch(:score, 0) <= 25 && hash.fetch(:weight, 1) < 2
    end
  end
end
