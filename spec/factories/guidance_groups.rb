# == Schema Information
#
# Table name: guidance_groups
#
#  id              :integer          not null, primary key
#  name            :string
#  org_id          :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  optional_subset :boolean
#  published       :boolean
#

FactoryBot.define do
  factory :guidance_group do
    name { Faker::Lorem.unique.word }
    org
    published true
    optional_subset false
    trait :unpublished do
      published false
    end
  end
end
