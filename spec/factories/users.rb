# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  accept_terms           :boolean
#  active                 :boolean          default(TRUE)
#  api_token              :string
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string(80)       default(""), not null
#  encrypted_password     :string
#  firstname              :string
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_token       :string
#  invited_by_type        :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  ldap_password          :string
#  ldap_username          :string
#  other_organisation     :string
#  recovery_email         :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0)
#  surname                :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  department_id          :integer
#  invited_by_id          :integer
#  language_id            :integer
#  org_id                 :integer
#
# Indexes
#
#  fk_rails_45f4f12508    (language_id)
#  fk_rails_f29bf9cdf2    (department_id)
#  index_users_on_email   (email)
#  index_users_on_org_id  (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (department_id => departments.id)
#  fk_rails_...  (language_id => languages.id)
#  fk_rails_...  (org_id => orgs.id)
#

FactoryBot.define do
  factory :user do
    org
    language     { Language.default }
    firstname    { Faker::Name.unique.first_name }
    surname      { Faker::Name.unique.last_name }
    email        { Faker::Internet.unique.safe_email }
    password     { "password" }
    accept_terms { true }

    trait :org_admin do
      after(:create) do |user, _evaluator|
        %w[modify_templates modify_guidance
           change_org_details
           use_api
           grant_permissions].each do |perm_name|
          user.perms << Perm.find_or_create_by(name: perm_name)
        end
      end
    end

    trait :super_admin do
      after(:create) do |user, _evaluator|
        %w[change_org_affiliation add_organisations
           grant_permissions use_api change_org_details grant_api_to_orgs
           modify_templates modify_guidance].each do |perm_name|
          user.perms << Perm.find_or_create_by(name: perm_name)
        end
      end
    end
  end
end
