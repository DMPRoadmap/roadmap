# frozen_string_literal: true

# == Schema Information
#
# Table name: research_outputs
#
#  id                      :integer          not null, primary key
#  abbreviation            :string
#  access                  :integer          default("open"), not null
#  byte_size               :bigint(8)
#  description             :text
#  display_order           :integer
#  is_default              :boolean          default(FALSE)
#  output_type             :integer          default("dataset"), not null
#  output_type_description :string
#  personal_data           :boolean
#  pid                     :string
#  release_date            :datetime
#  sensitive_data          :boolean
#  title                   :string
#  uuid                    :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  license_id              :bigint(8)
#  plan_id                 :integer
#
# Indexes
#
#  index_research_outputs_on_license_id  (license_id)
#  index_research_outputs_on_plan_id     (plan_id)
#
# Foreign Keys
#
#  fk_rails_...  (license_id => licenses.id)
#  fk_rails_...  (plan_id => plans.id)
#
FactoryBot.define do
  factory :research_output do
    license
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
      metadata_standards_count { 1 }
    end

    after(:create) do |research_output, evaluator|
      research_output.repositories = create_list(:repository, evaluator.repositories_count)
      research_output.metadata_standards = create_list(:metadata_standard,
                                                       evaluator.metadata_standards_count)
    end
  end
end
