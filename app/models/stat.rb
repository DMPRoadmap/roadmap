class Stat < ActiveRecord::Base
  belongs_to :org

  class << self
    def to_csv(stats)
      data = stats.map do |stat|
        { date: stat.date, count: stat.count }
      end
      Csvable.from_array_of_hashes(data)
    end
  end
end
