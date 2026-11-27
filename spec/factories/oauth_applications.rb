# frozen_string_literal: true

# == Schema Information
#
# Table name: oauth_application
#
# id:                 :integer
# name:               :string
# uid:                :string
# secret:             :string
# redirect_uri:       :text
# scopes:             :string
# confidential:       :boolean
# created_at:         :datetime
# updated_at:         :datetime

FactoryBot.define do
  factory :oauth_application, class: 'doorkeeper/application' do
    name { Faker::Lorem.unique.word }
    uid { SecureRandom.uuid }
    secret { SecureRandom.uuid }
    redirect_uri { "https://#{Faker::Internet.unique.domain_name}/callback" }
    scopes { 'read' }
  end
end
