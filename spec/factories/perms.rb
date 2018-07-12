# == Schema Information
#
# Table name: perms
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :perm do
    name { Faker::Company.catch_phrase }
  end
end
