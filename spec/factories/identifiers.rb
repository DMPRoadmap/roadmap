# frozen_string_literal: true

# == Schema Information
#
# Table name: identifiers
#
#  id                   :integer          not null, primary key
#  attrs                :text
#  identifiable_type    :string
#  value                :string           not null
#  created_at           :datetime
#  updated_at           :datetime
#  identifiable_id      :integer
#  identifier_scheme_id :integer
#
# Indexes
#
#  index_identifiers_on_identifiable_type_and_identifiable_id  (identifiable_type,identifiable_id)
#  index_identifiers_on_identifier_scheme_id_and_value         (identifier_scheme_id,value)
#  index_identifiers_on_scheme_and_type_and_id                 (identifier_scheme_id,identifiable_id,identifiable_type)
#

FactoryBot.define do
  factory :identifier do
    identifier_scheme
    for_user

    value { Faker::Lorem.word }
    attrs { {} }

    trait :for_plan do
      association :identifiable, factory: :plan
    end
    trait :for_org do
      association :identifiable, factory: :org
    end
    trait :for_user do
      association :identifiable, factory: :user
    end
  end
end
