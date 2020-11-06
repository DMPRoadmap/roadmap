# frozen_string_literal: true

# == Schema Information
#
# Table name: identifier_schemes
#
#  id                :integer          not null, primary key
#  active            :boolean
#  description       :string
#  context           :integer
#  logo_url          :text
#  name              :string
#  identifier_prefix :string
#  created_at        :datetime
#  updated_at        :datetime
#

FactoryBot.define do
  factory :identifier_scheme do
    name { Faker::Company.unique.name[0..29] }
    description { Faker::Movies::StarWars.quote }
    logo_url { Faker::Internet.url }
    identifier_prefix { "#{Faker::Internet.url}/" }
    active { true }

    transient do
      context_count { 1 }
    end

    after(:create) do |identifier_scheme, evaluator|
      (0..evaluator.context_count - 1).each do |idx|
        identifier_scheme.update("#{identifier_scheme.all_context[idx]}": true)
      end
    end
  end
end
