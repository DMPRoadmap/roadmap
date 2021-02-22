# frozen_string_literal: true

# == Schema Information
#
# Table name: research_outputs
#
#  id                      :bigint           not null, primary key
#  abbreviation            :string
#  access                  :integer          default(0), not null
#  byte_size               :bigint
#  description             :text
#  display_order           :integer
#  is_default              :boolean          default("false")
#  output_type             :integer          default(3), not null
#  output_type_description :string
#  personal_data           :boolean
#  release_date            :datetime
#  sensitive_data          :boolean
#  title                   :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  mime_type_id            :integer
#  plan_id                 :integer
#
# Indexes
#
#  index_research_outputs_on_output_type  (output_type)
#  index_research_outputs_on_plan_id      (plan_id)
#
FactoryBot.define do
  factory :research_output do
    abbreviation            { Faker::Lorem.unique.word }
    access                  { ResearchOutput.accesses.keys.sample }
    byte_size               { Faker::Number.number }
    description             { Faker::Lorem.paragraph }
    is_default              { [nil, true, false].sample }
    display_order           { Faker::Number.between(from: 1, to: 20) }
    output_type             { ResearchOutput.output_types.keys.sample }
    output_type_description { Faker::Lorem.sentence }
    personal_data           { [nil, true, false].sample }
    release_date            { Time.now + 1.month }
    sensitive_data          { [nil, true, false].sample }
    title                   { Faker::Music::PearlJam.song }

    transient do
      repositories_count { 1 }
    end

    after(:create) do |research_output, evaluator|
      research_output.repositories = create_list(:repository, evaluator.repositories_count)
    end
  end
end
