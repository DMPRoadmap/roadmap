module Actions
  module StatCreatedPlan
    class Generate
      class << self
        def full(org)
          OrgDateRangeable.split_months_from_creation(org) do |start_date, end_date|
            create_count_for_date(start_date: start_date, end_date: end_date, org: org)  
          end
        end

        def last_month(org)
          months = OrgDateRangeable.split_months_from_creation(org)
          last = months.last
          if last.present?
            create_count_for_date(start_date: last[:start_date], end_date: last[:end_date], org: org)
          end
        end
        
        def full_all_orgs
          Org.all.each do |org|
            full(org)
          end
        end

        def last_month_all_orgs
          Org.all.each do |org|
            last_month(org)
          end
        end

        private

        def count_plans(start_date: , end_date: , org:)
          users = User.where('users.org_id = ?', org.id)
          plans = Plan.where('plans.created_at >= ? AND plans.created_at <= ?', start_date, end_date)
          creator_admon = Role.with_access_flags(:creator, :administrator)
          
          Role.joins([:plan, :user]).merge(creator_admon).merge(users).merge(plans).select(:plan_id).distinct.count
        end

        def create_count_for_date(start_date:, end_date:, org:)
          count = count_plans(start_date: start_date, end_date: end_date, org: org)
          ::StatCreatedPlan.create(date: end_date.to_date, count: count, org_id: org.id)
        end
      end
    end
  end
end
