# == Schema Information
#
# Table name: regions
#
#  id           :integer          not null, primary key
#  abbreviation :string
#  description  :string
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryBot.define do
  factory :region do
    name { Faker::Address.unique.country }
    abbreviation { SecureRandom.hex(3)  }
    description { Faker::Lorem.sentence }
  end
end
