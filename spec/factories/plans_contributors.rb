# frozen_string_literal: true

# == Schema Information
#
# Table name: plans_contributors
#
#  id                   :integer          not null, primary key
#  plan_id              :integer
#  contributor_id       :integer
#  roles                :integer
#  created_at           :datetime
#  updated_at           :datetime
#
# Indexes
#
#  index_plans_contributors_on_roles (role)
#
# Foreign Keys
#
#  fk_rails_...  (plan_id => plans.id)
#  fk_rails_...  (contributor_id => contributors.id)
#

FactoryBot.define do
  factory :plans_contributor do
    plan
    contributor
    roles { 0 }

    transient do
      roles_count { 1 }
    end

    after(:create) do |plans_contributor, evaluator|
      (0..evaluator.roles_count - 1).each do |idx|
        plans_contributor.update("#{plans_contributor.all_roles[idx]}": true)
      end
    end
  end
end