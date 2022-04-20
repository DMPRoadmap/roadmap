# frozen_string_literal: true

module Api
<<<<<<< HEAD

  module V1

=======
  module V1
>>>>>>> upstream/master
    # Service that takes standard ActiveModel errors and contextualizes them
    # so that they relate to the structure of the JSON format used by the API
    # to help the caller understand the errors.
    # For example:
    #   "Plan identifiers value can't be blank" becomes "Dmp identifier value can't be blank"
    #   "Name can't be blank" becomes "Funder name can't be blank"
    #   "Contributors org name can't ..." becomes "Contact/Contributor affiliation name can't ..."
    class ContextualErrorService
<<<<<<< HEAD

      class << self

=======
      class << self
>>>>>>> upstream/master
        # Process the plan's errors and any of its associations
        # rubocop:disable Metrics/AbcSize
        def process_plan_errors(plan:)
          return [] if !plan.is_a?(Plan) || valid_plan?(plan: plan)

          errs = contextualize(errors: plan.errors)
          return errs unless plan.funder.present? || plan.grant.present?

          plan.funder.valid?
<<<<<<< HEAD
          errs << contextualize(errors: plan.funder.errors, context: "Funding")
          return errs unless plan.grant.present?

          plan.grant.valid?
          errs << contextualize(errors: plan.grant.errors, context: "Grant")
=======
          errs << contextualize(errors: plan.funder.errors, context: 'Funding')
          return errs unless plan.grant.present?

          plan.grant.valid?
          errs << contextualize(errors: plan.grant.errors, context: 'Grant')
>>>>>>> upstream/master
          errs.flatten.compact.uniq
        end
        # rubocop:enable Metrics/AbcSize

        # Add context to the standard error message
<<<<<<< HEAD
        def contextualize(errors:, context: "DMP")
=======
        # rubocop:disable Metrics/AbcSize
        def contextualize(errors:, context: 'DMP')
>>>>>>> upstream/master
          errs = errors.is_a?(ActiveModel::Errors) ? errors.full_messages : []
          errs = errors if errors.is_a?(Array) && errs.empty?
          return errs unless errs.any?

          errs.map do |msg|
<<<<<<< HEAD
            msg.gsub("org name", "affiliation name")
               .gsub("identifiers value", "identifier values")
               .gsub("Contributors", "Contact/Contributor")
=======
            msg.gsub('org name', 'affiliation name')
               .gsub('identifiers value', 'identifier values')
               .gsub('Contributors', 'Contact/Contributor')
>>>>>>> upstream/master
               .gsub(/^Identifiers/, "#{context.capitalize} identifier")
               .gsub(/^Name/, "#{context.capitalize} name")
               .gsub(/^Title/, "#{context.capitalize} title")
               .gsub(/^Value/, "#{context.capitalize} value")
          end
        end
<<<<<<< HEAD
=======
        # rubocop:enable Metrics/AbcSize
>>>>>>> upstream/master

        # Checks the plan and optional associations for validity
        def valid_plan?(plan:)
          plan.valid? &&
            (plan.funder.blank? || plan.funder.valid?) &&
            (plan.grant.blank? || plan.grant.value.present?)
        end
<<<<<<< HEAD

      end

    end

  end

=======
      end
    end
  end
>>>>>>> upstream/master
end
