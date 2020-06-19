# frozen_string_literal: true

class StatCreatedPlan

  class CreateOrUpdate

    class << self

      def do(start_date:, end_date:, org:, filtered: false)
        count = count_plans(start_date: start_date, end_date: end_date, org: org, filtered: filtered)
        by_template = plan_statistics(start_date: start_date, end_date: end_date, org: org, filtered: filtered)
        using_template = plan_statistics(start_date: start_date, end_date: end_date, org: org, own_templates: true, filtered: filtered)
        attrs = {
          date: end_date.to_date,
          org_id: org.id,
          count: count,
          details: { by_template: by_template, using_template: using_template },
          filtered: filtered
        }
        stat_created_plan = StatCreatedPlan.find_by(
          date: attrs[:date],
          org_id: attrs[:org_id],
          filtered: attrs[:filtered]
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

      def plans(start_date:, end_date:, filtered:)
        base = Plan
        base = base.stats_filter if filtered
        base.where(plans: { created_at: start_date..end_date })
      end

      def own_template_plans(org)
        Plan.joins(:template).where(templates: { org_id: org.id })
      end

      def count_plans(start_date:, end_date:, org:, filtered:)
        Role.joins(:plan, :user)
          .administrator
          .merge(users(org))
          .merge(plans(start_date: start_date, end_date: end_date, filtered: filtered))
          .select(:plan_id)
          .distinct
          .count
      end

      def plan_statistics(start_date:, end_date:, org:, filtered:, own_templates: false)
        roleable_plans = Role.joins([:plan, :user])
          .administrator
          .merge(plans(start_date: start_date, end_date: end_date, filtered: filtered))
        if own_templates
          roleable_plans = roleable_plans.merge(own_template_plans(org))
        else
          roleable_plans = roleable_plans.merge(users(org))
        end
        roleable_plan_ids = roleable_plans.pluck(:plan_id).uniq

        template_counts = Plan.joins(:template).where(id: roleable_plan_ids)
          .group("templates.family_id").count
        most_recent_versions = Template.where(family_id: template_counts.keys)
          .group(:family_id).maximum("version")
        most_recent_versions = most_recent_versions.map { |k, v| "#{k}=#{v}" }
        template_names = Template.where("CONCAT(family_id, '=', version) IN (?)",
          most_recent_versions).pluck(:family_id, :title)
        template_names.map do |t|
          { name: t[1], count: template_counts[t[0]] }
        end
      end

    end

  end

end
