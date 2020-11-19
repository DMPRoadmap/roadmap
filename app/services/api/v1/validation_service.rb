# frozen_string_literal: true

module Api

  module V1

    # Service used to validate incoming JSON
    class ValidationService

      class << self

        def plan_valid?(json:)
          json.present? && json[:title].present? && json[:contact].present? &&
            json[:contact][:mbox].present?

          # We either need a Template.id (creating) or a Plan.id (updating)
          # dmp_id = json[:dmp_id]&.fetch(:identifier, nil)
          # template_id(json: json).present? || dmp_id.present?
        end

        def identifier_valid?(json:)
          json.present? && json[:type].present? && json[:identifier].present?
        end

        def org_valid?(json:)
          json.present? && json[:name].present?
        end

        def contributor_valid?(json:, is_contact: false)
          return false unless json.present?
          return false unless json[:name].present? || json[:mbox].present?

          is_contact ? true : json[:role].present?
        end

        def funding_valid?(json:)
          return false unless json.present?

          funder_id = json.fetch(:funder_id, {})[:identifier]
          grant_id = json.fetch(:grant_id, {})[:identifier]
          json[:name].present? || funder_id.present? || grant_id.present?
        end

        def dataset_valid?(json:)
          # TODO: implement this once we support them in the DB
          json.present?
        end

      end

    end

  end

end
