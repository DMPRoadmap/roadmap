# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  firstname              :string
#  surname                :string
#  email                  :string           default(""), not null
#  orcid_id               :string
#  shibboleth_id          :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  encrypted_password     :string           default("")
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
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
#  accept_terms           :boolean
#  org_id                 :integer
#  api_token              :string
#  invited_by_id          :integer
#  invited_by_type        :string
#  language_id            :integer
#  recovery_email         :string
#  active                 :boolean          default(TRUE)
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
