module Api
  module V0
    class StatisticsPolicy < ApplicationPolicy
      attr_reader :user

      def initialize(user, statistic)
        raise Pundit::NotAuthorizedError, _("must be logged in") unless user
        unless user.org.token_permission_types.include? TokenPermissionType::STATISTICS
          raise Pundit::NotAuthorizedError, _("must have access to guidances api")
        end
        @user = user
        @statistic = statistic
      end

      ##
      # always allowed to see how many users joined your org within a date range
      def users_joined?
        true
      end

      def completed_plans?
        true
      end
      ##
      # need to check if your org owns this template
      def using_template?
        @statistic.org_id == @user.org_id
      end

      ##
      # always allowed to get plans by template
      def plans_by_template?
        true
      end

      ##
      # always allowed to get plans
      def plans?
        true
      end

    end
  end
end