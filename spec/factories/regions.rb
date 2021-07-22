# frozen_string_literal: true

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
    name { Faker::Address.country }
    abbreviation { SecureRandom.hex(2)  }
    description { Faker::Lorem.sentence }
  end
end
