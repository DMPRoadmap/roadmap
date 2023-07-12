# frozen_string_literal: true

module Api
  module V3
    # Base policy for Plan endpoints
    class DmpsPolicy < ApplicationPolicy
      attr_reader :user, :dmp

      class Scope
        attr_reader :user, :dmp

        def initialize(user, dmp)
          raise Pundit::NotAuthorizedError, 'must be logged in' unless user

          @user = user
          @dmp = dmp
        end

        def resolve
          Dmp.includes(narrative_attachment: [:blob])
             .where(user_id: @user.id, dmp_id: nil)
        end
      end
    end
  end
end
