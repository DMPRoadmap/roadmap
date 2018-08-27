# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  accept_terms           :boolean
#  active                 :boolean          default(TRUE)
#  api_token              :string(255)
#  confirmation_sent_at   :datetime
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(255)
#  email                  :string(80)       default(""), not null
#  encrypted_password     :string(255)
#  firstname              :string(255)
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_token       :string(255)
#  invited_by_type        :string(255)
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string(255)
#  ldap_password          :string(255)
#  ldap_username          :string(255)
#  other_organisation     :string(255)
#  recovery_email         :string(255)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  sign_in_count          :integer          default(0)
#  surname                :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invited_by_id          :integer
#  language_id            :integer
#  org_id                 :integer
#
# Indexes
#
#  fk_rails_45f4f12508    (language_id)
#  index_users_on_email   (email)
#  index_users_on_org_id  (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (language_id => languages.id)
#  fk_rails_...  (org_id => orgs.id)
#

FactoryBot.define do
  factory :user do
    org
    language     { Language.first || create(:language) }
    firstname    { Faker::Name.unique.first_name }
    surname      { Faker::Name.unique.last_name }
    email        { Faker::Internet.unique.safe_email }
    password     { "password" }
    accept_terms { true }
  end
end
