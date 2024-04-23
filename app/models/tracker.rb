# frozen_string_literal: true

# == Schema Information
#
# Table name: trackers
#
#  id         :integer          not null, primary key
#  code       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  org_id     :integer
#
# Indexes
#
#  index_trackers_on_org_id  (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#
class Tracker < ApplicationRecord
  belongs_to :org
  validates :code, format: { with: /\A\z|\AUA-[0-9]+-[0-9]+\z/,
                             message: 'wrong format' }
end
