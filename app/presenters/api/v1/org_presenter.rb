# frozen_string_literal: true

module Api

  module V1

    class OrgPresenter

      class << self

        def affiliation_id(identifiers:)
          id = identifiers.select { |id| id.identifier_scheme.name == "ror" }.first
          return id if id.present?

          identifiers.select { |id| id.identifier_scheme.name == "fundref" }.first
        end

      end

    end

  end

end
