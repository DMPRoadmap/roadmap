# == Schema Information
#
# Table name: token_permission_types
#
#  id               :integer          not null, primary key
#  token_type       :string
#  text_description :text
#  created_at       :datetime
#  updated_at       :datetime
#

FactoryBot.define do
  factory :token_permission_type do
    token_type { Faker::Lorem.word }
    text_description { Faker::Lorem.sentence }
  end
end
