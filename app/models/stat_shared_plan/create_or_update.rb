# frozen_string_literal: true

class StatSharedPlan

  class CreateOrUpdate

    class << self

      def do(start_date:, end_date:, org:)
        count = shared_plans(start_date: start_date, end_date: end_date, org_id: org.id)
        attrs = { date: end_date.to_date, count: count, org_id: org.id }

        stat_shared_plan = StatSharedPlan.find_by(
          date: attrs[:date],
          org_id: attrs[:org_id]
        )

        if stat_shared_plan.present?
          stat_shared_plan.update(attrs)
        else
          StatSharedPlan.create(attrs)
        end
      end

      private

      def users(org_id)
        User.where(users: {org_id: org_id })
      end

      def org_plan_ids(org_id)
        Role.joins(:user)
            .creator
            .merge(users(org_id))
            .pluck(:plan_id)
            .uniq
      end

      def shared_plans(start_date:, end_date:, org_id:)
        Role.not_creator
            .where(plan_id: org_plan_ids(org_id))
            .where(created_at: start_date..end_date)
            .count
      end

    end

  end

end
