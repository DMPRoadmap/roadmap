# frozen_string_literal: true

# == Schema Information
#
# Table name: question_options
#
#  id             :integer          not null, primary key
#  is_default     :boolean
#  number         :integer
#  text           :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  question_id    :integer
#  versionable_id :string(36)
#
# Indexes
#
#  index_question_options_on_question_id     (question_id)
#  index_question_options_on_versionable_id  (versionable_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#

FactoryBot.define do
  factory :question_option do
    question
    text { Faker::Lorem.sentence }
    sequence(:number)
    is_default { false }
  end
end
