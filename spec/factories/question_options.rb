# frozen_string_literal: true

# == Schema Information
#
# Table name: question_options
#
#  id          :integer          not null, primary key
#  is_default  :boolean
#  number      :integer
#  text        :string
#  created_at  :datetime
#  updated_at  :datetime
#  question_id :integer
#
# Indexes
#
#  index_question_options_on_question_id  (question_id)
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
