# frozen_string_literal: true

namespace :plan do
  desc 'Fetch citations for related identifiers that do not have one'
  task fetch_related_identifier_citations: :environment do
    RelatedIdentifier.where(citation: nil)
                     .or(RelatedIdentifier.where(citation: '')).each do |related|
      p "Fetching citation for: '#{related.value}'"
      related.citation = related.fetch_citation(doi: related.value, work_type: related.work_type) # , debug: true)
      p "    #{related.citation.presence || 'none found.'}"
      related.save if related.citation_changed?
    end
  end
end
