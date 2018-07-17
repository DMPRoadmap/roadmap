# == Schema Information
#
# Table name: org_identifiers
#
#  id                   :integer          not null, primary key
#  identifier           :string
#  attrs                :string
#  created_at           :datetime
#  updated_at           :datetime
#  org_id               :integer
#  identifier_scheme_id :integer
#

FactoryBot.define do
  factory :org_identifier do
    identifier { Faker::Lorem.word }
    attrs { Hash.new }
    org
    identifier_scheme
  end
end
