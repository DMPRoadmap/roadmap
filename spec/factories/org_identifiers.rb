# == Schema Information
#
# Table name: org_identifiers
#
#  id                   :integer          not null, primary key
#  attrs                :string
#  identifier           :string
#  created_at           :datetime
#  updated_at           :datetime
#  identifier_scheme_id :integer
#  org_id               :integer
#
# Indexes
#
#  org_identifiers_identifier_scheme_id_idx  (identifier_scheme_id)
#  org_identifiers_org_id_idx                (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (identifier_scheme_id => identifier_schemes.id)
#  fk_rails_...  (org_id => orgs.id)
#

FactoryBot.define do
  factory :org_identifier do
    identifier { Faker::Lorem.word }
    attrs { Hash.new }
    org
    identifier_scheme
  end
end
