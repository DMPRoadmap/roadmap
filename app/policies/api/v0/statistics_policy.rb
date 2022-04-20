# frozen_string_literal: true

module Api

  module V0
<<<<<<< HEAD

    class StatisticsPolicy < ApplicationPolicy

      attr_reader :user
=======
    # Security rules for API V0 Usage Statistic endpoints
    class StatisticsPolicy < ApplicationPolicy
      # NOTE: @user is the signed_in_user and @record is the statistic
>>>>>>> upstream/master

      def initialize(user, statistic)
        unless user.org.token_permission_types.include? TokenPermissionType::STATISTICS
          raise Pundit::NotAuthorizedError, _('must have access to guidances api')
        end

<<<<<<< HEAD
        @user = user
        @statistic = statistic
=======
        super(user, statistic)
>>>>>>> upstream/master
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
        @record.org_id == @user.org_id
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
<<<<<<< HEAD

=======
>>>>>>> upstream/master
end
