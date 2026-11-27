# frozen_string_literal: true

module Api
  module V2
    class TemplatesPolicy < ApplicationPolicy
      class Scope < Scope # rubocop:todo Style/Documentation
        def initialize(resource_owner) # rubocop:todo Lint/MissingSuper
          @resource_owner = resource_owner
        end

        def resolve
          # get the templates
          Template.for_api_v2(@resource_owner.org&.id)
        end
      end
    end
  end
end
