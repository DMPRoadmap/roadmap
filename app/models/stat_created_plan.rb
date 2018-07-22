class StatCreatedPlan < Stat
  extend OrgDateRangeable

  class << self
    def to_csv(created_plans)
      Stat.to_csv(created_plans)
    end
  end
end
