# == Schema Information
#
# Table name: answers
#
#  id           :integer          not null, primary key
#  is_common    :boolean          default(FALSE)
#  lock_version :integer          default(0)
#  text         :text
#  created_at   :datetime
#  updated_at   :datetime
#  dataset_id   :integer
#  plan_id      :integer
#  question_id  :integer
#  user_id      :integer
#
# Indexes
#
#  answers_plan_id_idx          (plan_id)
#  answers_question_id_idx      (question_id)
#  answers_user_id_idx          (user_id)
#  index_answers_on_dataset_id  (dataset_id)
#
# Foreign Keys
#
#  fk_rails_...  (dataset_id => datasets.id)
#  fk_rails_...  (plan_id => plans.id)
#  fk_rails_...  (question_id => questions.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :answer do
    text { Faker::Lorem.paragraph }
    plan
    user
    question
  end
end
