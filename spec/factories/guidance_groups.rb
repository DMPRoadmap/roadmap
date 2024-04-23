# frozen_string_literal: true

# == Schema Information
#
# Table name: guidance_groups
#
#  id              :integer          not null, primary key
#  name            :string
#  optional_subset :boolean          default(TRUE), not null
#  published       :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  org_id          :integer
#
# Indexes
#
#  guidance_groups_org_id_idx  (org_id)
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
