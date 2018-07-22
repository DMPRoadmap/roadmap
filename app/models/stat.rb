class Stat < ActiveRecord::Base
  belongs_to :org

  class << self
    def to_csv(stats)
      data = stats.reduce([]) do |acc, stat|
        acc << { date: stat.date, count: stat.count }
        acc
      end
      Csvable.from_array_of_hashes(data)
    end
  end
end
