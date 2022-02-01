# frozen_string_literal: true

module Api
  module V2
    # Contextualized errors for API V2 (e.g. "Contact identifier cannot be blank")
    class ContextualErrorService
      class << self
        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
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

          plan.related_identifiers.each do |related_identifier|
            rid_errs = find_related_identifier_errors(related_identifier: related_identifier)
            errs << rid_errs if rid_errs.present?
          end

          p_errs = find_project_errors(plan: plan)
          errs << p_errs if p_errs.present?

          plan.identifiers.each do |id|
            errs << "identifier: '#{id.value}' - #{id.errors.full_messages}" unless id.valid?
          end
          errs << "Plan: #{plan.errors.full_messages}" unless plan.valid?
          errs = errs.flatten.uniq

          # remove redundant errors for children
          errs.reject do |err|
            err.include?('Research outputs ') || err.include?('Related identifiers ') ||
              err.include?('Contributors ') || err.include?('Identifiers ')
          end
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
        # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

        private

        # Contextualize errors with the Project and its children
        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def find_project_errors(plan:)
          errs = []
          return errs unless plan.present? # && !plan.valid?

          a_errs = find_org_errors(org: plan.funder, label: 'Funder') if plan.funder.present?
          errs << a_errs if a_errs.any?

          if plan.grant.present? && !plan.grant.valid?
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
        def find_org_errors(org:, label: 'Affiliation')
          errs = []
          return errs unless org.present? && !org.valid?

          errs << org.errors.full_messages
          errs = errs.flatten.uniq
          errs.any? ? ["#{label}: '#{org.name}' : #{errs}"] : []
        end

        # Contextualize errors with the ContributorDataManagementPlan and its children
        # rubocop:disable Metrics/AbcSize
        def find_contributor_errors(contributor:)
          errs = []
          return errs unless contributor.present? && !contributor.valid?

          a_err = find_org_errors(org: contributor.org)
          errs << a_err if a_err.present?

          errs << contributor.errors.full_messages
          errs = errs.flatten.uniq
          # remove redundant error messages for associated Org
          errs = errs.reject { |err| err.include?('Org ') }
          errs.any? ? ["Contributor/Contact: '#{contributor&.name}' : #{errs}"] : []
        end
        # rubocop:enable Metrics/AbcSize

        # Contextualize errors with the RelatedIdentifiers
        def find_related_identifier_errors(related_identifier:)
          errs = []
          return errs unless related_identifier.present? && !related_identifier.valid?

          errs << related_identifier.errors.full_messages
          errs = errs.flatten.uniq
          errs.any? ? ["Related Identifier : #{errs}"] : []
        end
      end
    end
  end
end
