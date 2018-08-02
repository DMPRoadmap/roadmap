# == Schema Information
#
# Table name: guidances
#
#  id                :integer          not null, primary key
#  text              :text
#  guidance_group_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  question_id       :integer
#  published         :boolean
#

FactoryBot.define do
  factory :guidance do
    text { Faker::Lorem.sentence }
    guidance_group
    question
  end
end
