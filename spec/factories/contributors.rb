# frozen_string_literal: true

# == Schema Information
#
# Table name: contributors
#
#  id           :integer          not null, primary key
#  name         :string
#  email        :string
#  phone        :string
#  roles        :integer
#  org_id       :integer
#  plan_id      :integer
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_contributors_on_id      (id)
#  index_contributors_on_email   (email)
#  index_contributors_on_org_id  (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_id => orgs.id)
#  fk_rails_...  (plan_id => plans.id)

FactoryBot.define do
  factory :contributor do
    org
    name { Faker::Movies::StarWars.unique.character }
    email { Faker::Internet.unique.email }
    phone { Faker::PhoneNumber.phone_number_with_country_code }

    transient do
      roles_count { 1 }
    end

    before(:create) do |contributor, evaluator|
      (0..evaluator.roles_count - 1).each do |idx|
        contributor.send(:"#{contributor.all_roles[idx]}=", true)
      end
    end
  end
end
