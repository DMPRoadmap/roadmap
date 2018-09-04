class StatJoinedUser < Stat 
  extend OrgDateRangeable

  class << self
    def to_csv(joined_users)
      Stat.to_csv(joined_users)
    end
  end
end
