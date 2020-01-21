# == Schema Information
#
# Table name: answers
#
#  id                 :integer          not null, primary key
#  text               :text
#  plan_id            :integer
#  user_id            :integer
#  question_id        :integer
#  created_at         :datetime
#  updated_at         :datetime
#  lock_version       :integer          default("0")
#  is_common          :boolean          default("false")
#  research_output_id :integer
#
# Indexes
#
#  answers_plan_id_idx                  (plan_id)
#  answers_question_id_idx              (question_id)
#  answers_user_id_idx                  (user_id)
#  index_answers_on_research_output_id  (research_output_id)
#

FactoryBot.define do
  factory :answer do
    text { Faker::Lorem.paragraph }
    plan
    user
    question
  end
end
