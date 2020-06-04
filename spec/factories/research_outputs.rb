# == Schema Information
#
# Table name: research_outputs
#
#  id                      :integer          not null, primary key
#  abbreviation            :string
#  order                   :integer
#  fullname                :string
#  is_default              :boolean          default("false")
#  plan_id                 :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  pid                     :string
#  other_type_label        :string
#  research_output_type_id :integer
#
# Indexes
#
#  index_research_outputs_on_plan_id                  (plan_id)
#  index_research_outputs_on_research_output_type_id  (research_output_type_id)
#

FactoryBot.define do
  factory :research_output do
    abbreviation { Faker::Company.bs }
    fullname { Faker::Company.bs }
    sequence(:order)
    is_default { false }
    plan
    association :type, factory: :research_output_type

    trait :order do
      order { 1 }
    end
  end
end
