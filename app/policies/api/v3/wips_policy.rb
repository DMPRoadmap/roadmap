# frozen_string_literal: true

module Api
  module V3
    # Base policy for Plan endpoints
    class WipsPolicy < ApplicationPolicy
      attr_reader :user, :wip

      class Scope
        attr_reader :user, :wip

        def initialize(user, wip)
          raise Pundit::NotAuthorizedError, 'must be logged in' unless user

          @user = user
          @wip = wip
        end

        def resolve
          Wip.includes(narrative_attachment: [:blob]).where(user_id: @user.id)
        end
      end
    end
  end
end
