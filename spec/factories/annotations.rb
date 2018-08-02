# == Schema Information
#
# Table name: annotations
#
#  id          :integer          not null, primary key
#  question_id :integer
#  org_id      :integer
#  text        :text
#  type        :integer          default(0), not null
#  created_at  :datetime
#  updated_at  :datetime
#

FactoryBot.define do
  factory :annotation do
    question
    org
    text { Faker::Lorem.paragraph }
    type { [0,1].sample }
  end
end
