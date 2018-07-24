# == Schema Information
#
# Table name: plans
#
#  id                                :integer          not null, primary key
#  title                             :string
#  template_id                       :integer
#  created_at                        :datetime
#  updated_at                        :datetime
#  slug                              :string
#  grant_number                      :string
#  identifier                        :string
#  description                       :text
#  principal_investigator            :string
#  principal_investigator_identifier :string
#  data_contact                      :string
#  funder_name                       :string
#  visibility                        :integer          default(3), not null
#  data_contact_email                :string
#  data_contact_phone                :string
#  principal_investigator_email      :string
#  principal_investigator_phone      :string
#  feedback_requested                :boolean          default(FALSE)
#  complete                          :boolean          default(FALSE)
#

FactoryBot.define do
  factory :plan do
    title { Faker::Company.bs }
    template
    grant_number { SecureRandom.rand(1_000) }
    identifier { SecureRandom.hex }
    description { Faker::Lorem.paragraph }
    principal_investigator { Faker::Name.name }
    funder_name { Faker::Company.name }
    data_contact_email { Faker::Internet.safe_email }
    principal_investigator_email { Faker::Internet.safe_email }
    feedback_requested false
    complete false
    transient do
      answers 0
      guidance_groups 0
    end
    trait :creator do
      after(:create) { |obj| obj.roles << create(:role, creator: true) }
    end
    trait :organisationally_visible do
      visibility "organisationally_visible"
    end

    trait :publicly_visible do
      visibility "publicly_visible"
    end

    trait :is_test do
      visibility "is_test"
    end

    trait :privately_visible do
      visibility "privately_visible"
    end

    after(:create) do |plan, evaluator|
      create_list(:answer, evaluator.answers, plan: plan)
    end

    after(:create) do |plan, evaluator|
      plan.guidance_groups << create_list(:guidance_group, evaluator.guidance_groups)
    end

  end
end
