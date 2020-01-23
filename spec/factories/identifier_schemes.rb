# == Schema Information
#
# Table name: identifier_schemes
#
#  id               :integer          not null, primary key
#  active           :boolean
#  description      :string
#  for_auth         :boolean          default(FALSE)
#  for_orgs         :boolean          default(FALSE)
#  for_plans        :boolean          default(FALSE)
#  for_users        :boolean          default(FALSE)
#  logo_url         :text
#  name             :string
#  user_landing_url :string
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
    for_auth { false }
    for_orgs { false }
    for_plans { false }
    for_users { true }
  end
end
