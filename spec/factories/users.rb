# frozen_string_literal: true
# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  firstname              :string
#  surname                :string
#  email                  :string(80)       default(""), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  encrypted_password     :string           default("")
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default("0")
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  other_organisation     :string
#  dmponline3             :boolean
#  accept_terms           :boolean
#  org_id                 :integer
#  api_token              :string
#  invited_by_id          :integer
#  invited_by_type        :string
#  language_id            :integer
#  recovery_email         :string
#  active                 :boolean          default("true")
#  department_id          :integer
#
# Indexes
#
#  users_email_key        (email) UNIQUE
#  users_language_id_idx  (language_id)
#  users_org_id_idx       (org_id)
#

FactoryBot.define do
  factory :user do
    org
    firstname    { Faker::Name.unique.first_name }
    surname      { Faker::Name.unique.last_name }
    email        { Faker::Internet.unique.safe_email }
    password     { "password" }
    accept_terms { true }

    trait :org_admin do
      after(:create) do |user, evaluator|
        %w[modify_templates modify_guidance
           change_org_details
           grant_permissions].each do |perm_name|
          user.perms << Perm.find_or_create_by(name: perm_name)
        end
      end
    end

    trait :super_admin do
      after(:create) do |user, evaluator|
        %w[change_org_affiliation add_organisations
           grant_permissions use_api change_org_details grant_api_to_orgs
           modify_templates modify_guidance].each do |perm_name|
          user.perms << Perm.find_or_create_by(name: perm_name)
        end
      end
    end
  end
end
