# frozen_string_literal: true

namespace :plan do
  desc 'Fetch citations for related identifiers that do not have one'
  task fetch_related_identifier_citations: :environment do
    RelatedIdentifier.where(citation: nil)
                     .or(RelatedIdentifier.where(citation: '')).each do |related|
      p "Fetching citation for: '#{related.value}'"
      related.fetch_citation(doi: related.value, work_type: related.work_type)
      p "    #{related.citation.present? ? related.citation : 'none found.'}"
      related.save if related.citation_changed?
    end
  end
end
