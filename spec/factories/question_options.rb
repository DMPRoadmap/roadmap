# == Schema Information
#
# Table name: question_options
#
#  id          :integer          not null, primary key
#  question_id :integer
#  text        :string
#  number      :integer
#  is_default  :boolean
#  created_at  :datetime
#  updated_at  :datetime
#

FactoryBot.define do
  factory :question_option do
    question
    text { Faker::Lorem.sentence }
    sequence(:number)
    is_default false
  end
end
