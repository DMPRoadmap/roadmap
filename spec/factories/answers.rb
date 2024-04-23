# frozen_string_literal: true

# == Schema Information
#
# Table name: answers
#
#  id                 :integer          not null, primary key
#  is_common          :boolean          default(FALSE)
#  lock_version       :integer          default(0)
#  text               :text
#  created_at         :datetime
#  updated_at         :datetime
#  plan_id            :integer
#  question_id        :integer
#  research_output_id :integer
#  user_id            :integer
#
# Indexes
#
#  answers_plan_id_idx                  (plan_id)
#  answers_question_id_idx              (question_id)
#  answers_user_id_idx                  (user_id)
#  index_answers_on_research_output_id  (research_output_id)
#
# Foreign Keys
#
#  fk_rails_...  (plan_id => plans.id)
#  fk_rails_...  (question_id => questions.id)
#  fk_rails_...  (research_output_id => research_outputs.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :answer do
    text { Faker::Lorem.paragraph }
    plan
    user
    question
    research_output { FactoryBot.create(:research_output, plan: plan) }
  end
end
