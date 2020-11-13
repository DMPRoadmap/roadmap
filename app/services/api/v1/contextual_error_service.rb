# frozen_string_literal: true

module Api

  module V1

    # Service that takes standard ActiveModel errors and contextualizes them
    # so that they relate to the structure of the JSON format used by the API
    # to help the caller understand the errors.
    # For example:
    #   "Plan identifiers value can't be blank" becomes "Dmp identifier value can't be blank"
    #   "Name can't be blank" becomes "Funder name can't be blank"
    #   "Contributors org name can't ..." becomes "Contact/Contributor affiliation name can't ..."
    class ContextualErrorService

      class << self

        # Process the plan's errors and any of its associations
        # rubocop:disable Metrics/AbcSize
        def process_plan_errors(plan:)
          return [] if !plan.is_a?(Plan) || valid_plan?(plan: plan)

          errs = contextualize(errors: plan.errors)
          return errs unless plan.funder.present? || plan.grant.present?

          plan.funder.valid?
          errs << contextualize(errors: plan.funder.errors, context: "Funding")
          return errs unless plan.grant.present?

          plan.grant.valid?
          errs << contextualize(errors: plan.grant.errors, context: "Grant")
          errs.flatten.compact.uniq
        end
        # rubocop:enable Metrics/AbcSize

        # Add context to the standard error message
        def contextualize(errors:, context: "DMP")
          errs = errors.is_a?(ActiveModel::Errors) ? errors.full_messages : []
          errs = errors if errors.is_a?(Array) && errs.empty?
          return errs unless errs.any?

          errs.map do |msg|
            msg.gsub("org name", "affiliation name")
               .gsub("identifiers value", "identifier values")
               .gsub("Contributors", "Contact/Contributor")
               .gsub(/^Identifiers/, "#{context.capitalize} identifier")
               .gsub(/^Name/, "#{context.capitalize} name")
               .gsub(/^Title/, "#{context.capitalize} title")
               .gsub(/^Value/, "#{context.capitalize} value")
          end
        end

        # Checks the plan and optional associations for validity
        def valid_plan?(plan:)
          plan.valid? &&
            (plan.funder.blank? || plan.funder.valid?) &&
            (plan.grant.blank? || plan.grant.valid?)
        end

      end

    end

  end

end
