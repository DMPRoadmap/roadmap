# frozen_string_literal: true

module Api
  module V0
    # Security rules for API V0 Plan endpoints
    class PlansPolicy < ApplicationPolicy
      # NOTE: @user is the signed_in_user and @record is the plan

      def initialize(user, plan)
        unless user.org.token_permission_types.include? TokenPermissionType::PLANS
          raise Pundit::NotAuthorizedError, _('must have access to plans api')
        end

        super
      end

      ##
      # users can create a plan if their template exists
      def create?
        @record.present?
      end

      def index?
        @user.can_org_admin?
      end
    end
  end
end
