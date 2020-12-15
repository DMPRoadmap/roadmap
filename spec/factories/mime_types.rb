# frozen_string_literal: true

# == Schema Information
#
# Table name: mime_types
#
#  id          :bigint           not null, primary key
#  category    :string           not null
#  description :string           not null
#  value       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_mime_types_on_value  (value)
#
FactoryBot.define do
  factory :mime_type do
    category { %w[application audio audio image text video].sample }
    description { Faker::Lorem.sentence }
    value { "#{category}/#{Faker::Lorem.word}" }
  end
end
