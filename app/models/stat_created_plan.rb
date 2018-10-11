# == Schema Information
#
# Table name: stats
#
#  id         :integer          not null, primary key
#  count      :integer          default(0)
#  date       :date             not null
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  org_id     :integer
#

class StatCreatedPlan < Stat
  extend OrgDateRangeable

  class << self
    def to_csv(created_plans)
      Stat.to_csv(created_plans)
    end
  end
end
