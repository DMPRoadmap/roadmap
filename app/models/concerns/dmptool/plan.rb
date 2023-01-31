# frozen_string_literal: true

module Dmptool
  # DMPTool extensions to the base Plan model
  module Plan
    extend ActiveSupport::Concern

    class_methods do
      # rubocop:disable Metrics/AbcSize
      def faceted_search(facets: {}, sort_by: 'plans.featured desc, plans.created_at desc')
        return order(sort_by) unless facets.is_a?(ActionController::Parameters)

        funder_ids = facets.fetch(:funder_ids, [])
        org_ids = facets.fetch(:institution_ids, [])
        language_ids = facets.fetch(:language_ids, [])
        subject_ids = facets.fetch(:subject_ids, [])

        clause = []
        clause << 'plans.funder_id IN (:funder_ids)' if funder_ids.any?
        clause << 'plans.org_id IN (:org_ids)' if org_ids.any?
        clause << 'plans.language_id IN (:language_ids)' if language_ids.any?
        clause << 'plans.research_domain_id IN (:subject_ids)' if subject_ids.any?
        return order(sort_by) if clause.blank?

        where(clause.join(' AND '), funder_ids: funder_ids, org_ids: org_ids, language_ids: language_ids,
                                    subject_ids: subject_ids)
          .order(sort_by)
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
