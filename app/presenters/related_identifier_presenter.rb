# frozen_string_literal: true

class RelatedIdentifierPresenter

  attr_accessor :related_identifiers

  def initialize(plan:)
    @related_identifiers = plan.related_identifiers
    @related_identifiers = @related_identifiers.order(:work_type, :created_at)
  end

  # Returns all of the work types for the select box
  def selectable_related_identifiers
    RelatedIdentifier.work_types.keys.map { |key| [key.humanize, key] }
  end

  # Return the related identifiers for read only display
  def for_display
    return [] unless related_identifiers.any?

    related_identifiers.map do |related|
      next unless related.is_a?(RelatedIdentifier)

      dflt = "%{work_type} - <a href=\"%{url}\" target=\"_blank\">%{url}</a>" % {
        work_type: related.work_type.humanize,
        url: related.value
      }
      related.citation.present? ? related.citation : dflt
    end
  end

end