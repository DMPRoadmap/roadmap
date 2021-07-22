# frozen_string_literal: true

# == Schema Information
#
# Table name: guidances
#
#  id                :integer          not null, primary key
#  published         :boolean
#  text              :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  guidance_group_id :integer
#
# Indexes
#
#  index_guidances_on_guidance_group_id  (guidance_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (guidance_group_id => guidance_groups.id)
#

FactoryBot.define do
  factory :guidance do
    text { Faker::Lorem.sentence }
    guidance_group
    published { false }
    before(:create) do |guidance, _evaluator|
      guidance.themes << create_list(:theme, 2)
    end
  end
end
