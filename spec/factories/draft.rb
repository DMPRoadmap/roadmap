# frozen_string_literal: true

require 'securerandom'

# == Schema Information
#
# Table name: drafts
#
#  id          :integer          not null, primary key
#  draft_id    :string           not null
#  user_id     :integer
#  metadata    :json
#  dmp_id      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :draft do
    user
    draft_id { "#{Time.now.strftime('%Y%m%d')}-#{SecureRandom.hex(6)}" }
    metadata { { dmp: { title: Faker::Music::PearlJam.song } } }
  end
end
