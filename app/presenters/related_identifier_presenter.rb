# frozen_string_literal: true

# Helpers for displaying RelatedIdentifiers
class RelatedIdentifierPresenter
  attr_accessor :related_identifiers

  def initialize(plan:)
    @related_identifiers = plan.related_identifiers
    @related_identifiers = @related_identifiers.order(:work_type, :created_at)
  end

  # Returns all of the work types for the select box
  def selectable_related_identifiers
    RelatedIdentifier.work_types.keys.map { |key| [key.humanize, key] }.sort { |a, b| a <=> b }
  end

  # Return the related identifiers for read only display
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def for_display
    return [] unless related_identifiers.any?

    related_identifiers.map do |related|
      next unless related.is_a?(RelatedIdentifier)

      dflt = "#{related.work_type&.humanize} - #{related.value}"
      link = format('%{work_type} - <a href="%{url}" target="_blank">%{url}</a>',
                    work_type: related.work_type&.humanize, url: related.value)
      if related.citation.present?
        related.citation
      else
        (related.value&.start_with?('http') ? link : dflt)
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
