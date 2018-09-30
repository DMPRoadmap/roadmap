# frozen_string_literal: true

# == Schema Information
#
# Table name: stats
#
#  id         :integer          not null, primary key
#  count      :integer          default(0)
#  date       :date             not null
#  details    :text
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  org_id     :integer
#

class Stat < ActiveRecord::Base

  extend OrgDateRangeable

  belongs_to :org

  validates_uniqueness_of :type, scope: [:date, :org_id]

  class << self

    def to_csv(stats)
      data = stats.map do |stat|
        { date: stat.date, count: stat.count }
      end
      Csvable.from_array_of_hashes(data)
    end

  end

end
