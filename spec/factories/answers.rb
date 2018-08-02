# == Schema Information
#
# Table name: answers
#
#  id           :integer          not null, primary key
#  text         :text
#  plan_id      :integer
#  user_id      :integer
#  question_id  :integer
#  created_at   :datetime
#  updated_at   :datetime
#  lock_version :integer          default(0)
#

FactoryBot.define do
  factory :answer do
    text { Faker::Lorem.paragraph }
    plan
    user
    question
  end
end
