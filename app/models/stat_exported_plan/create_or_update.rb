# frozen_string_literal: true

class StatExportedPlan

  class CreateOrUpdate

    class << self

      def do(start_date:, end_date:, org:, filtered: false)
        count = exported_plans(start_date: start_date, end_date: end_date, org_id: org.id, filtered: filtered)
        attrs = { date: end_date.to_date, count: count, org_id: org.id, filtered: filtered}

        stat_exported_plan = StatExportedPlan.find_by(
          date: attrs[:date],
          org_id: attrs[:org_id],
          filtered: attrs[:filtered]
        )

        if stat_exported_plan.present?
          stat_exported_plan.update(attrs)
        else
          StatExportedPlan.create(attrs)
        end
      end

      private

      def users(org_id)
        User.where(users: {org_id: org_id })
      end

      def org_plan_ids(org_id:, filtered:)
        plans = Plan.all
        plans = plans.stats_filter if filtered
        Role.joins(:plan, :user)
            .creator
            .merge(users(org_id))
            .merge(plans)
            .pluck(:plan_id)
            .uniq
      end

      def exported_plans(start_date:, end_date:, org_id:, filtered:)
        ExportedPlan.where(plan_id: org_plan_ids(org_id: org_id, filtered: filtered))
            .where(created_at: start_date..end_date)
            .count
      end

    end

  end

end
