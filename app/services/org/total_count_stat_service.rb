# frozen_string_literal: true

class Org

  class TotalCountStatService

    class << self

      def call(filtered: false)
        total = build_from_joined_user
        build_from_created_plan(filtered, total)
        total.values
      end

      private

      def build_model(org_name:, total_users: 0, total_plans: 0)
        {
          org_name: org_name,
          total_users: total_users,
          total_plans: total_plans
        }
      end

      def reducer_body(acc, count, key_target)
        org_name = count[:org_name]
        count = count[:count]

        if acc[org_name].present?
          acc[org_name][key_target] = count
        else
          args = { org_name: org_name }
          args[key_target] = count
          acc[org_name] = build_model(args)
        end

        acc
      end

      def build_from_joined_user(total = {})
        # Users have no concept of filtering (at the moment)
        joined_user_count = Org::TotalCountJoinedUserService.call
        joined_user_count.reduce(total) do |acc, count|
          reducer_body(acc, count, :total_users)
        end
      end

      def build_from_created_plan(filtered, total = {})
        created_plan_count = Org::TotalCountCreatedPlanService.call(filtered: filtered)
        created_plan_count.reduce(total) do |acc, count|
          reducer_body(acc, count, :total_plans)
        end
      end

    end

  end

end
