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
    abbreviation { SecureRandom.hex(2) }
    default_language true
  end
end
