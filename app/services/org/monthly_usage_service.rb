# frozen_string_literal: true

class Org

  class MonthlyUsageService

    class << self

      def call(current_user, filtered: false)
        total = build_from_joined_user(current_user, filtered)
        build_from_created_plan(current_user, filtered, total)
        build_from_shared_plan(current_user, filtered, total)
        build_from_exported_plan(current_user, filtered, total)
        total.values
      end

      private

      def build_model(month:, new_plans: 0, new_users: 0, downloads: 0, plans_shared: 0)
        {
          month: month,
          new_plans: new_plans,
          new_users: new_users,
          downloads: downloads,
          plans_shared: plans_shared
        }
      end

      def reducer_body(acc, rec, key_target)
        month = rec.date.strftime("%b-%y")
        count = rec.count

        if acc[month].present?
          acc[month][key_target] = count
        else
          args = { month: month }
          args[key_target] = count
          acc[month] = build_model(args)
        end

        acc
      end

      def build_from_joined_user(current_user, filtered, total = {})
        # rubocop:disable Metrics/LineLength
        joined_users = Stat::StatJoinedUser.monthly_range(org: current_user.org, filtered: filtered).order(:date)
        # rubocop:enable Metrics/LineLength
        joined_users.reduce(total) do |acc, rec|
          reducer_body(acc, rec, :new_users)
        end
      end

      def build_from_created_plan(current_user, filtered, total = {})
        # rubocop:disable Metrics/LineLength
        created_plans = Stat::StatCreatedPlan.monthly_range(org: current_user.org, filtered: filtered).order(:date)
        # rubocop:enable Metrics/LineLength
        created_plans.reduce(total) do |acc, rec|
          reducer_body(acc, rec, :new_plans)
        end
      end

      def build_from_shared_plan(current_user, filtered, total = {})
        # rubocop:disable Metrics/LineLength
        shared_plans = Stat::StatSharedPlan.monthly_range(org: current_user.org, filtered: filtered).order(:date)
        # rubocop:enable Metrics/LineLength
        shared_plans.reduce(total) do |acc, rec|
          reducer_body(acc, rec, :plans_shared)
        end
      end

      def build_from_exported_plan(current_user, filtered, total = {})
        # rubocop:disable Metrics/LineLength
        exported_plans = Stat::StatExportedPlan.monthly_range(org: current_user.org, filtered: filtered).order(:date)
        # rubocop:enable Metrics/LineLength
        exported_plans.reduce(total) do |acc, rec|
          reducer_body(acc, rec, :downloads)
        end
      end

    end

  end

end
