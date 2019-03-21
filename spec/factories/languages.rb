# == Schema Information
#
# Table name: languages
#
#  id               :integer          not null, primary key
#  abbreviation     :string(510)
#  default_language :boolean
#  description      :string(510)
#  name             :string(510)
#

FactoryBot.define do
  factory :language do
    name { Faker::Language.name }
    description { "Language for #{name}" }
    abbreviation { Faker::Language.abbreviation }
    default_language { false }
    trait :with_dialect do
      abbreviation {
        pre = ("a".."z").to_a.shuffle.take(2).join
        suf = ("A".."Z").to_a.shuffle.take(2).join
        [pre, suf].join("_")
       }
    end
  end
end
