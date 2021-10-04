# frozen_string_literal: true

module Api
  module V0
    # Security rules for API V0 Guidance endpoints
    class GuidancePolicy < ApplicationPolicy
      attr_reader :user, :guidance

      def initialize(user, guidance)
        raise Pundit::NotAuthorizedError, _('must be logged in') unless user
        unless user.org.token_permission_types.include? TokenPermissionType::GUIDANCES
          raise Pundit::NotAuthorizedError, _('must have access to guidances api')
        end

        super(user)
        @user = user
        @guidance = guidance
      end

      ##
      # is the plan editable by the user
      def show?
        Guidance.can_view(@user, @guidance.id)
      end

      ##
      # always allowed as index chooses which guidances to display
      def index?
        true
      end
    end
  end
end
