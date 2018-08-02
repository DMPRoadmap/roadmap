# == Schema Information
#
# Table name: notes
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  text        :text
#  archived    :boolean
#  answer_id   :integer
#  archived_by :integer
#  created_at  :datetime
#  updated_at  :datetime
#

FactoryBot.define do
  factory :note do
    user
    text { Faker::Lorem.sentence }
    answer
    archived false
  end
end
