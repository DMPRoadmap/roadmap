# frozen_string_literal: true

FactoryBot.define do
  factory :tracker do
    org { nil }
    code { "UA-#{Faker::Number.number(digits: 5)}-#{Faker::Number.number(digits: 2)}" }
  end
end
