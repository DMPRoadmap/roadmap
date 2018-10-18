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

class StatJoinedUser < Stat 
  extend OrgDateRangeable

  class << self
    def to_csv(joined_users)
      Stat.to_csv(joined_users)
    end
  end
end
