# frozen_string_literal: true

module Api
  module V1
    # Helper class for the API V1 affiliation sections
    class OrgPresenter
      class << self
        def affiliation_id(identifiers:, fundref: false)
          return identifiers.find { |id| id.identifier_scheme&.name == 'ror' } unless fundref

          identifiers.find { |id| id.identifier_scheme&.name == 'fundref' }
        end
      end
    end
  end
end
