# frozen_string_literal: true

# == Schema Information
#
# Table name: oauth_applications
#
#  id              :integer          not null, primary key
#  callback_method :integer          default(0)
#  callback_uri    :string(255)
#  confidential    :boolean          default(TRUE)
#  contact_email   :string(255)
#  contact_name    :string(255)
#  description     :string(255)
#  homepage        :string(255)
#  last_access     :datetime
#  logo_name       :string(255)
#  logo_uid        :string(255)
#  name            :string(255)      not null
#  redirect_uri    :text(65535)
#  scopes          :string(255)      default(""), not null
#  secret          :string(255)      default(""), not null
#  trusted         :boolean          default(FALSE), not null
#  uid             :string(255)      default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  org_id          :integer
#  user_id         :bigint(8)
#
# Indexes
#
#  index_oauth_applications_on_name     (name)
#  index_oauth_applications_on_uid      (uid) UNIQUE
#  index_oauth_applications_on_user_id  (user_id)
#

FactoryBot.define do
  factory :api_client, aliases: %i[oauth_application] do
    name { Faker::Lorem.unique.word }
    homepage { Faker::Internet.url }
    contact_name { Faker::Movies::StarWars.character }
    contact_email { Faker::Internet.email }
    client_id { SecureRandom.uuid }
    client_secret { SecureRandom.uuid }
  end
end
