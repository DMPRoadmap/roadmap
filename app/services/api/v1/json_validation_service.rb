# frozen_string_literal: true

module Api

  module V1

    # Service used to validate incoming JSON
    class JsonValidationService

      # rubocop:disable Layout/LineLength
      BAD_PLAN_MSG = _(":title and the contact's :mbox are both required fields").freeze
      BAD_ID_MSG = _(":type and :identifier are required for all ids").freeze
      BAD_ORG_MSG = _(":name is required for every :affiliation and :funding").freeze
      BAD_CONTRIB_MSG = _(":role and either the :name or :email are required for each :contributor").freeze
      BAD_FUNDING_MSG = _(":name, :funder_id or :grant_id are required for each funding").freeze
      BAD_DATASET_MSSG = _(":title is required for each :dataset").freeze
      # rubocop:enable Layout/LineLength

      class << self

        def plan_valid?(json:)
          json.present? && json[:title].present? && json[:contact].present? &&
            json[:contact][:mbox].present?
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

        # rubocop:disable Metrics/AbcSize
        # Scans the entire JSON document for invalid metadata and returns
        # friendly errors to help the caller resolve the issue
        def validation_errors(json:)
          errs = []
          return [_("invalid JSON")] unless json.present?

          errs << BAD_PLAN_MSG unless plan_valid?(json: json)
          if json[:dmp_id].present?
            errs << BAD_ID_MSG unless identifier_valid?(json: json[:dmp_id])
          end

          # Handle Contact
          errs << contributor_validation_errors(json: json[:contact])

          # Handle Contributors
          errs << json.fetch(:contributor, []).map do |contributor|
            contributor_validation_errors(json: contributor)
          end

          # Handle the Project and Fundings
          json.fetch(:project, []).each do |project|
            errs << project.fetch(:funding, []).map do |funding|
              funding_validation_errors(json: funding)
            end
          end

          # Handle Datasets (eventually)
          # errs << json.fetch(:dataset, []).map do |dataset|
          #   dataset_validation_errors(json: dataset)
          # end
          errs.flatten.compact.uniq
        end
        # rubocop:enable Metrics/AbcSize

        def contributor_validation_errors(json:)
          errs = []
          if json.present?
            errs << BAD_CONTRIB_MSG unless contributor_valid?(json: json,
                                                              is_contact: true)
            errs << org_validation_errors(json: json[:affiliation]) if json[:affiliation].present?
            id = json.fetch(:contributor_id, json[:contact_id])
            if id.present?
              errs << BAD_ID_MSG unless identifier_valid?(json: id)
            end
          end
          errs
        end

        def funding_validation_errors(json:)
          errs = []
          return errs unless json.present?

          errs << BAD_FUNDING_MSG unless funding_valid?(json: json)
          errs << org_validation_errors(json: json)
          if json[:grant_id].present?
            errs << BAD_ID_MSG unless identifier_valid?(json: json[:grant_id])
          end
          errs
        end

        def org_validation_errors(json:)
          errs = []
          return errs unless json.present?

          errs << BAD_ORG_MSG unless org_valid?(json: json)
          id = json.fetch(:affiliation_id, json[:funder_id])
          if id.present?
            errs << BAD_ID_MSG unless identifier_valid?(json: id)
          end
          errs
        end

      end

    end

  end

end
