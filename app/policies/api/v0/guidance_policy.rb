# frozen_string_literal: true

module Api
  module V0
    # Security rules for API V0 Guidance endpoints
    class GuidancePolicy < ApplicationPolicy
      # NOTE: @user is the signed_in_user and @record is the guidance

      def initialize(user, guidance)
        unless user.org.token_permission_types.include? TokenPermissionType::GUIDANCES
          raise Pundit::NotAuthorizedError, _('must have access to guidances api')
        end

        super
      end

      ##
      # is the plan editable by the user
      def show?
        Guidance.can_view(@user, @record.id)
      end

      ##
      # always allowed as index chooses which guidances to display
      def index?
        true
      end
    end
  end
end
