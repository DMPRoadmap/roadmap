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

class StatSharedPlan < Stat

  class << self

    def to_csv(shared_plans)
      Stat.to_csv(shared_plans)
    end

  end

end
