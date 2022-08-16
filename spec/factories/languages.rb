# frozen_string_literal: true

# == Schema Information
#
# Table name: languages
#
#  id               :integer          not null, primary key
#  abbreviation     :string(255)
#  default_language :boolean
#  description      :string(255)
#  name             :string(255)
#

FactoryBot.define do
  factory :language do
    name { Faker::Movies::StarWars.unique.specie }
    description { "Language for #{name}" }
    default_language { false }
    trait :with_dialect do
      abbreviation do
        pre = ('a'..'z').to_a.shuffle.take(2).join
        suf = ('A'..'Z').to_a.shuffle.take(2).join
        [pre, suf].join('_')
      end
    end
  end
end
