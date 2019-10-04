# == Schema Information
#
# Table name: regions
#
#  id         :integer          not null, primary key
#  name       :string(30)       not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :region do
    name { Faker::Movies::StarWars.unique.planet }
  end
end
