# frozen_string_literal: true

module Api
  module V1
    # Helper class for the API V1 affiliation sections
    class OrgPresenter
      class << self
        def affiliation_id(identifiers:, funder: false)
          ror_id = identifiers.find { |id| id.identifier_scheme&.name == 'ror' }
          fundref_id = identifiers.find { |id| id.identifier_scheme&.name == 'fundref' }
          # Return the ROR unless the caller is working with a funder and we don't have a ROR for them
          !funder || funder && ror_id.nil? ? ror_id : fundref_id
        end
      end
    end
  end
end
