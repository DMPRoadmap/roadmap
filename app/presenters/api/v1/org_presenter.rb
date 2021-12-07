# frozen_string_literal: true

module Api
  module V1
    # Helper class for the API V1 affiliation sections
    class OrgPresenter
      # rubocop:disable Metrics/CyclomaticComplexity
      class << self
        def affiliation_id(identifiers:, fundref: false)
          ident = identifiers.select { |id| id.identifier_scheme&.name == 'fundref' }.first if fundref
          return ident if ident.present? && fundref

          identifiers.select { |id| id.identifier_scheme&.name == 'ror' }.first
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity
    end
  end
end
