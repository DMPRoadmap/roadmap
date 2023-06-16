# frozen_string_literal: true

require 'securerandom'

# == Schema Information
#
# Table name: themes
#
#  id          :integer          not null, primary key
#  identifier  :string           not null
#  user_id     :integer
#  metadata    :json
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :wip do
    # user
    # identifier
    metadata { { dmp: { title: Faker::Lorem.unique.sentence } } }
  end
end
