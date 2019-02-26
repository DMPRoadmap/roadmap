# == Schema Information
#
# Table name: org_regions
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  org_id     :integer
#  region_id  :integer
#
# Indexes
#
#  index_org_regions_on_org_id     (org_id)
#  index_org_regions_on_region_id  (region_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#  fk_rails_...  (region_id => regions.id)
#

FactoryBot.define do
  factory :org_region do
    org { nil }
    region { nil }
  end
end
