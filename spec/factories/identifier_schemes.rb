# == Schema Information
#
# Table name: identifier_schemes
#
#  id               :integer          not null, primary key
#  active           :boolean
#  description      :string
#  logo_url         :text
#  name             :string
#  user_landing_url :text
#  created_at       :datetime
#  updated_at       :datetime
#

FactoryBot.define do
  factory :identifier_scheme do
    name { Faker::Company.unique.name[0..29] }
    description { Faker::Movies::StarWars.quote }
    logo_url { Faker::Internet.url }
    user_landing_url { Faker::Internet.url }
    active { true }
  end
end
