# frozen_string_literal: true

module Api
  module V3
    # Base policy for Plan endpoints
    class DraftsPolicy < ApplicationPolicy
      attr_reader :user, :draft

      class Scope
        attr_reader :user, :draft

        def initialize(user, draft)
          raise Pundit::NotAuthorizedError, 'must be logged in' unless user

          @user = user
          @draft = draft
        end

        def resolve
          Draft.includes(narrative_attachment: [:blob])
               # .where(user_id: @user.id, dmp_id: nil)
        end
      end
    end
  end
end
