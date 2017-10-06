module Api
  module V0
    class PlansPolicy < ApplicationPolicy
      attr_reader :user
      attr_reader :template

      def initialize(user, template)
        raise Pundit::NotAuthorizedError, _("must be logged in") unless user
        unless user.org.token_permission_types.include? TokenPermissionType::PLANS
          raise Pundit::NotAuthorizedError, _("must have access to plans api")
        end
        @user     = user
        @template = template
      end

      ##
      # users can create a plan if their template exists
      def create?
        @template.present?
      end
    end
  end
end