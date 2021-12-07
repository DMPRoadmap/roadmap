# frozen_string_literal: true

module Api
  module V2
    # Contextualized errors for API V2 (e.g. "Contact identifier cannot be blank")
    class ContextualErrorService
      class << self
        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def contextualize_errors(plan:)
          errs = []
          return errs unless plan.present?

          plan.research_outputs.each do |dataset|
            d_errs = find_dataset_errors(dataset: dataset)
            errs << d_errs if d_errs.present?
          end

          plan.contributors.each do |contributor|
            c_errs = find_contributor_errors(contributor: contributor)
            errs << c_errs if c_errs.present?
          end

          p_errs = find_project_errors(plan: plan)
          errs << p_errs if p_errs.present?

          plan.identifiers.each do |id|
            errs << "identifier: '#{id.value}' - #{id.errors.full_messages}" unless id.valid?
          end
          errs << "Plan: #{plan.errors.full_messages}" unless plan.valid?
          errs.flatten.uniq
          errs
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

        private

        # Contextualize errors with the Project and its children
        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def find_project_errors(plan:)
          errs = []
          return errs unless plan.present? && !plan.valid?

          a_errs = find_org_errors(org: plan.funder) if plan.funder.present?
          errs << a_errs if a_errs.any?

          unless plan.grant.present? && plan.grant.valid?
            g_errs = "grant identifier '#{plan.grant.value}' : #{plan.grant.errors.full_messages}"
          end
          errs << g_errs if g_errs.is_a?(Array) && g_errs.any?

          errs = errs.flatten.uniq
          errs.any? ? ["Project : #{errs}"] : []
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

        # Contextualize errors with the Dataset and its children
        def find_dataset_errors(dataset:)
          errs = []
          return errs unless dataset.present? && !dataset.valid?

          errs << dataset.errors.full_messages
          errs = errs.flatten.uniq
          errs.any? ? ["Dataset : #{errs}"] : []
        end

        # Contextualize errors with the Affiliation and its children
        # rubocop:disable Metrics/AbcSize
        def find_org_errors(org:)
          errs = []
          return errs unless org.present? && !org.valid?

          id_errs = org.identifiers.map do |id|
            next if id.valid?

            "identifier '#{id.value}' : #{id.errors.full_messages}"
          end
          errs << id_errs if id_errs.any?
          errs << org.errors.full_messages
          errs = errs.flatten.uniq
          errs.any? ? ["Affiliation: '#{org.name}' : #{errs}"] : []
        end
        # rubocop:enable Metrics/AbcSize

        # Contextualize errors with the ContributorDataManagementPlan and its children
        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def find_contributor_errors(contributor:)
          errs = []
          return errs unless contributor.present? && !contributor.valid?

          a_err = find_org_errors(org: contributor.org)
          errs << a_err if a_err.present?

          id_errs = contributor.identifiers.map do |id|
            next if id.valid?

            "identifier '#{id.value}' : #{id.errors.full_messages}"
          end
          errs << id_errs if id_errs.any?
          errs << contributor.errors.full_messages
          errs = errs.flatten.uniq
          errs.any? ? ["Contributor/Contact: '#{contributor&.name}' : #{errs}"] : []
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      end
    end
  end
end
