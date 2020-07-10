# frozen_string_literal: true

# == Schema Information
#
# Table name: guidance_groups
#
#  id              :integer          not null, primary key
#  name            :string
#  optional_subset :boolean          default(FALSE), not null
#  published       :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  org_id          :integer
#
# Indexes
#
#  index_guidance_groups_on_org_id  (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#

FactoryBot.define do
  factory :guidance_group do
    name { Faker::Lorem.unique.word }
    org
    published { true }
    optional_subset { false }
    trait :unpublished do
      published { false }
    end
  end
end
