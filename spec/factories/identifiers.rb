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
#  identifier_scheme_id :integer          not null
#
# Indexes
#
#  index_identifiers_on_identifiable_type_and_identifiable_id  (identifiable_type,identifiable_id)
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
