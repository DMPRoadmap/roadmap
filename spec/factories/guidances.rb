# == Schema Information
#
# Table name: guidances
#
#  id                :integer          not null, primary key
#  text              :text
#  guidance_group_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  published         :boolean
#
# Indexes
#
#  guidances_guidance_group_id_idx  (guidance_group_id)
#

FactoryBot.define do
  factory :guidance do
    text { Faker::Lorem.sentence }
    guidance_group
    published { false }
    before(:create) do |guidance, evaluator|
      guidance.themes << create_list(:theme, 2)
    end
  end
end
