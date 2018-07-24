# == Schema Information
#
# Table name: languages
#
#  id               :integer          not null, primary key
#  abbreviation     :string
#  description      :string
#  name             :string
#  default_language :boolean
#

FactoryBot.define do
  factory :language do
    name "English"
    description "Test language English"
    abbreviation { ("a".."z").to_a.shuffle.take(2).join }
    default_language true
    trait :with_dialect do
      abbreviation {
        pre = ("a".."z").to_a.shuffle.take(2).join
        suf = ("A".."Z").to_a.shuffle.take(2).join
        [pre, suf].join("_")
       }
    end
  end
end
