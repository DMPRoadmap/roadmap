# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  accept_terms           :boolean
#  active                 :boolean
#  api_token              :string(510)
#  confirmation_sent_at   :datetime
#  confirmation_token     :string(510)
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(510)
#  dmponline3             :boolean
#  email                  :string(80)       default(""), not null
#  encrypted_password     :string(510)      default("")
#  firstname              :string(510)
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_token       :string(510)
#  invited_by_type        :string(510)
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string(510)
#  other_organisation     :string(510)
#  recovery_email         :string(510)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(510)
#  sign_in_count          :integer          default(0)
#  surname                :string(510)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invited_by_id          :integer
#  language_id            :integer
#  org_id                 :integer
#
# Indexes
#
#  users_email_key        (email) UNIQUE
#  users_language_id_idx  (language_id)
#  users_org_id_idx       (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (language_id => languages.id)
#  fk_rails_...  (org_id => orgs.id)
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
        %w[modify_templates modify_guidance change_org_details grant_permissions].each do |perm_name|
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
