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
# Indexes
#
#  org_identifiers_identifier_scheme_id_idx  (identifier_scheme_id)
#  org_identifiers_org_id_idx                (org_id)
#

FactoryBot.define do
  factory :org_identifier do
    identifier { Faker::Lorem.word }
    attrs { Hash.new }
    org
    identifier_scheme
  end
end
