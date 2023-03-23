# frozen_string_literal: true

module Api
  module V1
    # Helper class for the API V1 affiliation sections
    class OrgPresenter
      class << self
        def affiliation_id(identifiers:)
          ident = identifiers.find { |id| id.identifier_scheme&.name == 'ror' }
          return ident if ident.present?

          identifiers.find { |id| id.identifier_scheme&.name == 'fundref' }
        end
      end
    end
  end
end
