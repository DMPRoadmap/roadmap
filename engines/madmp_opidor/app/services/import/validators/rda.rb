# frozen_string_literal: true

module Import
  module Validators
    # Service used to convert plan from RDA DMP Commons Standars Format
    # to Standard Format
    class Rda < Api::V1::JsonValidationService
      class << self
        BAD_PLAN_MSG = _(":title and the contact's :mbox are both required fields").freeze
        BAD_ID_MSG = _(':type and :identifier are required for all ids').freeze
        BAD_ORG_MSG = _(':name is required for every :affiliation and :funding').freeze
        BAD_CONTRIB_MSG = _(':role and either the :name or :email are required for each :contributor').freeze
        BAD_FUNDING_MSG = _(':name, :funder_id or :grant_id are required for each funding').freeze
        BAD_DATASET_MSSG = _(':title is required for each :dataset').freeze
        def contributor_validation_errors(json:)
          errs = []
          if json.present? && !contributor_valid?(json:,
                                                  is_contact: true)
            errs << BAD_CONTRIB_MSG
            # id = json.fetch(:contributor_id, json[:contact_id])
            # errs << BAD_ID_MSG if id.present? && !identifier_valid?(json: id)
          end
          errs
        end

        def funding_validation_errors(json:)
          errs = []
          return errs unless json.present?

          errs << BAD_FUNDING_MSG unless funding_valid?(json:)
          # errs << BAD_ID_MSG if json[:grant_id].present? && !identifier_valid?(json: json[:grant_id])
          errs
        end
      end
    end
  end
end
