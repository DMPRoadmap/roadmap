# == Schema Information
#
# Table name: research_output_types
#
#  id         :integer          not null, primary key
#  label      :string           not null
#  slug       :string           not null
#  is_other   :boolean          default("false"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :research_output_type do
    label { Faker::Company.bs }
    slug { Faker::Internet.domain_word }
    is_other { false }
  end
end