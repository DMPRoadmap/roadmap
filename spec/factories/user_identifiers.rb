# == Schema Information
#
# Table name: user_identifiers
#
#  id                   :integer          not null, primary key
#  identifier           :string
#  created_at           :datetime
#  updated_at           :datetime
#  user_id              :integer
#  identifier_scheme_id :integer
#
# Indexes
#
#  user_identifiers_identifier_scheme_id_idx  (identifier_scheme_id)
#  user_identifiers_user_id_idx               (user_id)
#

FactoryBot.define do
  factory :user_identifier do
    identifier { SecureRandom.hex }
    user
    identifier_scheme
  end
end
