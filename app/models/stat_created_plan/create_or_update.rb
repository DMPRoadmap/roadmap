# frozen_string_literal: true

class StatCreatedPlan

  class CreateOrUpdate

    class << self

      def do(start_date:, end_date:, org:)
        count = count_plans(start_date: start_date, end_date: end_date, org: org)
        by_template = by_template(start_date: start_date, end_date: end_date, org: org)
        attrs = {
          date: end_date.to_date,
          org_id: org.id,
          count: count,
          details: { by_template: by_template }
        }
        stat_created_plan = StatCreatedPlan.find_by(
          date: attrs[:date],
          org_id: attrs[:org_id]
        )

        if stat_created_plan.present?
          stat_created_plan.update(attrs)
        else
          StatCreatedPlan.create(attrs)
        end
      end

      private

      def users(org)
        User.where(users: { org_id: org.id })
      end

      def plans(start_date:, end_date:)
        Plan.where(plans: { created_at: start_date..end_date })
      end

      def creator_admin
        Role.with_access_flags(:creator, :administrator)
      end

      def count_plans(start_date:, end_date:, org:)
        users = users(org)
        plans = plans(start_date: start_date, end_date: end_date)

        Role.joins([:plan, :user])
          .merge(creator_admin)
          .merge(users)
          .merge(plans)
          .select(:plan_id)
          .distinct
          .count
      end

      def by_template(start_date:, end_date:, org:)
        users = users(org)
        plans = plans(start_date: start_date, end_date: end_date)
        roleable_plan_ids = Role.joins([:plan, :user])
          .merge(creator_admin)
          .merge(users)
          .merge(plans)
          .select(:plan_id)
          .distinct
        template_counts = Plan.where(id: roleable_plan_ids).group(:template_id).count
        template_names = Template.where(id: template_counts.keys).pluck(:id, :title)
        template_names.map do |t|
          { name: t[1], count: template_counts[t[0]] }
        end
      end

    end

  end

end
