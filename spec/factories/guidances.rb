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
#  question_id       :integer
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
    published false
  end
end
