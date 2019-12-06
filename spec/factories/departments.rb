# frozen_string_literal: true

# == Schema Information
#
# Table name: departments
#
#  id         :integer          not null, primary key
#  code       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  org_id     :integer
#
# Indexes
#
#  index_departments_on_org_id  (org_id)
#

FactoryBot.define do
  factory :department do
    name { Faker::Commerce.department }
    code { SecureRandom.hex(5) }
    org_id { Faker::Number.number(digits: 5) }
  end
end
